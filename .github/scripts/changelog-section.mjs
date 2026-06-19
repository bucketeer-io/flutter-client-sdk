#!/usr/bin/env node
// Extracts a single release's section from CHANGELOG.md and prints it to stdout.
//
// release-please builds the GitHub Release body from the release PR notes (i.e.
// the conventional commits it parsed), NOT from the committed CHANGELOG.md.
// That means the "Native SDK Changes" block injected by augment-changelog.mjs
// never reaches the GitHub Release. This script lets the release workflow
// re-sync the release body from the (already augmented) CHANGELOG.md.
//
// Usage:
//   node .github/scripts/changelog-section.mjs --tag v2.2.2
//   node .github/scripts/changelog-section.mjs --version 2.2.2 --changelog CHANGELOG.md
//
// Output:
//   The body of the matching release section (heading line excluded so it
//   mirrors release-please's own release-body format) with the native-sdk
//   sentinel comments stripped.

import fs from "node:fs/promises";
import process from "node:process";

const CHANGELOG_PATH = "CHANGELOG.md";
const SENTINEL_START = "<!-- native-sdk-changes:start -->";
const SENTINEL_END = "<!-- native-sdk-changes:end -->";

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--tag") args.tag = argv[++i];
    else if (a === "--version") args.version = argv[++i];
    else if (a === "--changelog") args.changelogPath = argv[++i];
    else throw new Error(`Unknown argument: ${a}`);
  }
  return args;
}

function stripSentinels(text) {
  return text
    .split(/\r?\n/)
    .filter((line) => line.trim() !== SENTINEL_START && line.trim() !== SENTINEL_END)
    .join("\n");
}

function extractSection(changelog, version) {
  // release-please (release-type "simple") writes headings like:
  //   ## [2.2.2](https://github.com/.../compare/v2.2.1...v2.2.2) (2026-06-18)
  // Match the heading for the requested version, tolerating both linked
  // (`## [x.y.z](...)`) and bare (`## x.y.z`) forms.
  const v = escapeRegex(version);
  const headingRegex = new RegExp(`^## \\[?${v}\\]?(?:[ (]|$)`, "m");
  const headingMatch = changelog.match(headingRegex);
  if (!headingMatch) {
    throw new Error(`Could not find a CHANGELOG section for version ${version}`);
  }

  const headingIdx = headingMatch.index;
  const afterHeading = headingIdx + headingMatch[0].length;
  // Find the end of the heading line, then look for the next `## ` heading.
  const lineEnd = changelog.indexOf("\n", afterHeading);
  const bodyStart = lineEnd === -1 ? changelog.length : lineEnd + 1;

  const nextHeadingRegex = /\n## /g;
  nextHeadingRegex.lastIndex = bodyStart;
  const nextMatch = nextHeadingRegex.exec(changelog);
  const bodyEnd = nextMatch ? nextMatch.index : changelog.length;

  return changelog.slice(bodyStart, bodyEnd);
}

async function main() {
  const args = parseArgs(process.argv);
  const changelogPath = args.changelogPath || CHANGELOG_PATH;
  const version = (args.version || args.tag || "").replace(/^v/, "").trim();
  if (!version) {
    throw new Error("Provide --tag or --version");
  }

  const changelog = await fs.readFile(changelogPath, "utf8");
  const section = extractSection(changelog, version);
  const body = stripSentinels(section).trim();

  if (!body) {
    throw new Error(`CHANGELOG section for version ${version} is empty`);
  }

  process.stdout.write(`${body}\n`);
}

main().catch((err) => {
  console.error(err.stack || err.message || String(err));
  process.exit(1);
});
