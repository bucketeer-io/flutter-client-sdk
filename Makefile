setup:
	npm install

deps:
	flutter pub get
	cd example && flutter pub get

analyze:
	dart analyze lib/
	cd example && flutter analyze

format:
	dart format lib/ example/lib

format-check:
	dart format lib/ example/lib
	test -z "$$(git diff --name-only)"

build-android:
	cd example && flutter build apk --no-tree-shake-icons

build-ios:
	cd example && flutter build ios --no-codesign --no-tree-shake-icons

unit-test:
	flutter test --coverage --coverage-path=./coverage/lcov.info
