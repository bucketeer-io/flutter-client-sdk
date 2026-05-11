#!/usr/bin/env node
// Augments CHANGELOG.md with native SDK release notes for the topmost release.
//
// Reads .github/native-sdk-changelog.config.json to learn which dependency files
// to inspect, fetches GitHub release bodies for every native version between
// the base ref (typically main) and HEAD, aggregates them by section, and
// splices a "Native SDK Changes" block under the latest release heading.
//
// The block is enclosed in sentinel HTML comments so it can be removed and
// regenerated cleanly on every run (idempotent across release-please force
// pushes).
//
// Usage:
//   node .github/scripts/augment-changelog.mjs --base-ref origin/main
//
// Env:
//   GH_TOKEN  GitHub token used by the `gh` CLI to fetch release bodies.

import { execFileSync } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";

const CONFIG_PATH = ".github/native-sdk-changelog.config.json";
const CHANGELOG_PATH = "CHANGELOG.md";
const SENTINEL_START = "<!-- native-sdk-changes:start -->";
const SENTINEL_END = "<!-- native-sdk-changes:end -->";

function gh(args) {
  return execFileSync("gh", args, { encoding: "utf8", stdio: ["ignore", "pipe", "inherit"] });
}

function git(args) {
  return execFileSync("git", args, { encoding: "utf8", stdio: ["ignore", "pipe", "inherit"] });
}

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parseSemver(v) {
  const cleaned = String(v).replace(/^v/, "").trim();
  const match = cleaned.match(/^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$/);
  if (!match) return null;
  return [Number(match[1]), Number(match[2]), Number(match[3])];
}

function compareSemver(a, b) {
  const pa = parseSemver(a);
  const pb = parseSemver(b);
  if (!pa || !pb) return String(a).localeCompare(String(b));
  for (let i = 0; i < 3; i++) {
    if (pa[i] !== pb[i]) return pa[i] - pb[i];
  }
  return 0;
}

async function readVersion(filePath, regex, ref) {
  let content;
  if (ref) {
    try {
      content = git(["show", `${ref}:${filePath}`]);
    } catch (err) {
      throw new Error(`Could not read ${filePath} at ${ref}: ${err.message}`);
    }
  } else {
    content = await fs.readFile(filePath, "utf8");
  }
  const m = content.match(new RegExp(regex));
  if (!m) {
    throw new Error(`Could not match ${regex} in ${filePath}${ref ? ` at ${ref}` : ""}`);
  }
  return m[1];
}

function fetchReleasesBetween(repo, fromVersion, toVersion) {
  // GitHub Releases via gh CLI. Walk the most recent 100 releases and filter
  // to (fromVersion, toVersion]. 100 is enough for any wrapper SDK that bumps
  // a few times per year; bump if needed.
  const raw = gh([
    "release",
    "list",
    "--repo",
    repo,
    "--limit",
    "100",
    "--json",
    "tagName,name,publishedAt",
  ]);
  const releases = JSON.parse(raw);
  const inRange = releases
    .map((r) => ({ ...r, version: r.tagName.replace(/^v/, "") }))
    .filter((r) => parseSemver(r.version))
    .filter((r) => compareSemver(r.version, fromVersion) > 0 && compareSemver(r.version, toVersion) <= 0)
    .sort((a, b) => compareSemver(b.version, a.version));

  // Fetch bodies one-by-one so we don't pull bodies for unrelated releases.
  for (const r of inRange) {
    const body = gh([
      "release",
      "view",
      r.tagName,
      "--repo",
      repo,
      "--json",
      "body",
      "--jq",
      ".body",
    ]);
    r.body = body || "";
  }
  return inRange;
}

function parseReleaseBody(body) {
  // release-please bodies look like:
  //   ### Features
  //
  //   * item one ([#1](url))
  //   * item two
  //
  //   ### Bug Fixes
  //   ...
  //
  // Be lenient: accept ## or ### headings (release-please uses ###), and
  // accept either `*` or `-` bullets.
  const sections = {};
  const lines = body.split(/\r?\n/);
  let current = null;
  for (const rawLine of lines) {
    const line = rawLine.replace(/\s+$/, "");
    const heading = line.match(/^#{2,4}\s+(.+?)\s*$/);
    if (heading) {
      const title = heading[1].trim();
      // Skip anchor headings like the version range header that release-please
      // sometimes emits at the top of a body (it does not for our setup, but
      // safe to ignore non-section ones if encountered).
      current = title;
      sections[current] ??= [];
      continue;
    }
    if (!current) continue;
    const bullet = line.match(/^\s*[-*]\s+(.+)$/);
    if (bullet) {
      sections[current].push(bullet[1].trim());
    }
  }
  // Drop empty sections.
  for (const k of Object.keys(sections)) {
    if (sections[k].length === 0) delete sections[k];
  }
  return sections;
}

function aggregateSections(releases) {
  const all = {};
  for (const r of releases) {
    const sections = parseReleaseBody(r.body || "");
    for (const [name, items] of Object.entries(sections)) {
      all[name] ??= [];
      for (const item of items) {
        if (!all[name].includes(item)) all[name].push(item);
      }
    }
  }
  return all;
}

function rewriteItem(item, native) {
  // 1. Strip the trailing commit-hash link release-please appends, e.g.
  //    " ([abc1234](https://github.com/.../commit/abc1234...))".
  let out = item.replace(
    /\s*\(\[[0-9a-f]{6,40}\]\(https:\/\/github\.com\/[^)]+\/commit\/[0-9a-f]+\)\)\s*$/,
    "",
  );

  // 2. Disambiguate bare issue refs by prefixing with the native repo's short
  //    name. Only rewrite when the URL points to the native repo so we don't
  //    accidentally rewrite cross-repo links.
  const repoEsc = escapeRegex(native.repo);
  const issueRefRegex = new RegExp(
    `\\[#(\\d+)\\]\\((https://github\\.com/${repoEsc}/(?:issues|pull)/\\d+)\\)`,
    "g",
  );
  out = out.replace(issueRefRegex, `[${native.shortName}#$1]($2)`);

  return out.trim();
}

function renderNativeSection(native, fromVersion, toVersion, sections, config) {
  const compareUrl = `https://github.com/${native.repo}/compare/v${fromVersion}...v${toVersion}`;
  const lines = [];
  lines.push(`#### ${native.name} ([v${fromVersion}...v${toVersion}](${compareUrl}))`);
  lines.push("");

  const skipPatterns = (config.skipPatterns || []).map((p) => new RegExp(p));
  const ordered = config.sectionOrder || [];
  const seen = new Set();
  const emitSection = (name, items) => {
    const filtered = items
      .map((it) => rewriteItem(it, native))
      .filter((it) => it.length > 0)
      .filter((it) => !skipPatterns.some((re) => re.test(it)));
    if (filtered.length === 0) return;
    seen.add(name);
    lines.push(`##### ${name}`);
    lines.push("");
    for (const item of filtered) {
      lines.push(`* ${item}`);
    }
    lines.push("");
  };

  for (const name of ordered) {
    if (sections[name]) emitSection(name, sections[name]);
  }
  // Emit any unexpected sections after the configured order, alphabetised.
  for (const name of Object.keys(sections).sort()) {
    if (seen.has(name)) continue;
    emitSection(name, sections[name]);
  }

  return lines.join("\n").trimEnd();
}

function spliceIntoChangelog(changelog, augmentation) {
  // Drop any existing sentinel block first so we always start from the
  // release-please-generated baseline. This is what makes the workflow safe
  // to re-run after release-please force-pushes.
  const sentinelRegex = new RegExp(
    `\\n*${escapeRegex(SENTINEL_START)}[\\s\\S]*?${escapeRegex(SENTINEL_END)}\\n*`,
    "g",
  );
  let cleaned = changelog.replace(sentinelRegex, "\n");

  // Find the topmost `## ` heading (the new release).
  const firstHeadingMatch = cleaned.match(/^## .+$/m);
  if (!firstHeadingMatch) {
    throw new Error("Could not find a release heading (`## ...`) in CHANGELOG.md");
  }
  const firstHeadingIdx = cleaned.indexOf(firstHeadingMatch[0]);
  const afterFirstHeading = firstHeadingIdx + firstHeadingMatch[0].length;

  // Find the next `## ` heading (start of previous release).
  const nextHeadingRegex = /\n## /g;
  nextHeadingRegex.lastIndex = afterFirstHeading;
  const nextMatch = nextHeadingRegex.exec(cleaned);
  const insertionPoint = nextMatch ? nextMatch.index : cleaned.length;

  const before = cleaned.slice(0, insertionPoint).replace(/\s+$/, "");
  const after = cleaned.slice(insertionPoint);

  const block = [
    "",
    "",
    SENTINEL_START,
    "",
    augmentation,
    SENTINEL_END,
    "",
  ].join("\n");

  return `${before}${block}${after.startsWith("\n") ? after : `\n${after}`}`;
}

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--base-ref") args.baseRef = argv[++i];
    else if (a === "--config") args.configPath = argv[++i];
    else if (a === "--changelog") args.changelogPath = argv[++i];
    else if (a === "--dry-run") args.dryRun = true;
    else throw new Error(`Unknown argument: ${a}`);
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv);
  const baseRef = args.baseRef || "origin/main";
  const configPath = args.configPath || CONFIG_PATH;
  const changelogPath = args.changelogPath || CHANGELOG_PATH;

  const config = JSON.parse(await fs.readFile(configPath, "utf8"));
  if (!Array.isArray(config.natives) || config.natives.length === 0) {
    console.log("No native SDKs configured, nothing to do.");
    return;
  }

  const augmentations = [];
  for (const native of config.natives) {
    const newVersion = await readVersion(native.versionFile, native.versionRegex);
    let oldVersion;
    try {
      oldVersion = await readVersion(native.versionFile, native.versionRegex, baseRef);
    } catch (err) {
      console.warn(`[${native.name}] could not read base version, skipping: ${err.message}`);
      continue;
    }

    if (compareSemver(newVersion, oldVersion) <= 0) {
      console.log(`[${native.name}] no upgrade (${oldVersion} -> ${newVersion}), skipping`);
      continue;
    }

    console.log(`[${native.name}] ${oldVersion} -> ${newVersion}, fetching release notes`);
    let releases;
    try {
      releases = fetchReleasesBetween(native.repo, oldVersion, newVersion);
    } catch (err) {
      console.warn(`[${native.name}] failed to fetch releases: ${err.message}`);
      continue;
    }
    if (releases.length === 0) {
      console.warn(`[${native.name}] no GitHub releases found in (${oldVersion}, ${newVersion}], skipping`);
      continue;
    }
    console.log(`[${native.name}] found ${releases.length} release(s): ${releases.map((r) => r.tagName).join(", ")}`);

    const sections = aggregateSections(releases);
    if (Object.keys(sections).length === 0) {
      console.warn(`[${native.name}] release bodies contained no parseable sections, skipping`);
      continue;
    }
    augmentations.push(renderNativeSection(native, oldVersion, newVersion, sections, config));
  }

  if (augmentations.length === 0) {
    console.log("No native SDK upgrades found, leaving CHANGELOG.md untouched.");
    return;
  }

  const intro = [
    "### Native SDK Changes",
    "",
    "This release also brings the following changes from the underlying native SDKs.",
  ].join("\n");
  const fullBlock = `${intro}\n\n${augmentations.join("\n\n")}\n`;

  const original = await fs.readFile(changelogPath, "utf8");
  const updated = spliceIntoChangelog(original, fullBlock);

  if (updated === original) {
    console.log("CHANGELOG.md already up to date.");
    return;
  }

  if (args.dryRun) {
    console.log("--- diff (dry run) ---");
    console.log(updated);
    return;
  }

  await fs.writeFile(changelogPath, updated);
  console.log(`Updated ${changelogPath}.`);
}

main().catch((err) => {
  console.error(err.stack || err.message || String(err));
  process.exit(1);
});
