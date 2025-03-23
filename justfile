bundle_prefix := home_directory()
prefix := join(bundle_prefix, '.local')
bin := join(prefix, 'bin')

out := 'Out'
xcodeproj := 'gabber.xcodeproj'
xcodescheme := 'gabber'
xcderived := join('DerivedData', 'gabber')
xcarchive := join(out, 'Gabber.xcarchive')

swiftlint_reporter := if env('CI', 'false') == 'true' { 'github-actions-logging' } else { 'emoji' }

_xcode config = 'Release' *args:
    xcodebuild \
        -project {{xcodeproj}} \
        -scheme {{xcodescheme}} \
        -configuration {{config}} \
        -derivedDataPath {{xcderived}} \
        -skipPackagePluginValidation \
        -skipMacroValidation \
        {{args}}

_deps-xcode: (_xcode 'Debug' '-resolvePackageDependencies')

_deps-npm:
    npm install

# Check formatting and linting
check: check-format check-lint

# Check linting
check-lint: check-lint-xcode check-lint-npm

# Check linting for XCode project
check-lint-xcode: _deps-xcode
    ./{{xcderived}}/SourcePackages/artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/swiftlint-*-macos/bin/swiftlint \
        --strict \
        --reporter {{swiftlint_reporter}} \
        gabber git-gabber

# Check linting for browser extension
check-lint-npm: _deps-npm
    npm run lint

# Check formatting
check-format: check-format-swift check-format-other

# Check formatting for Swift files
check-format-swift:
    swift format lint --recursive gabber git-gabber

# Check formatting for other files
check-format-other: _deps-npm
    npx prettier --check .

# Build the app
build config = 'Release': (_xcode config)

# Create XCode archive
archive config = 'Release': (_xcode config '-archivePath' xcarchive 'archive')

# Create a DMG from the archive
dmg: archive
    hdiutil create \
        -volname "Gabber" \
        -srcfolder {{xcarchive}}/Products/Applications/Gabber.app \
        -ov -format UDZO \
        {{out}}/Gabber.dmg

# Install the app and git-gabber
install: archive
    cp -r {{xcarchive}}/Products/Applications/Gabber.app {{bundle_prefix}}/Applications
    install -m 755 {{xcarchive}}/Products/usr/local/bin/git-gabber {{bin}}/git-gabber

_out:
    mkdir -p {{out}}

# Build the extension
extension: _out
    npm run ext:build

# Sign the extension
sign-extension: _out
    FIREFOX_API_KEY=$(cat .api-key) \
    FIREFOX_API_SECRET=$(cat .api-secret) \
        npm run ext:sign

# Clean up
clean:
    rm -rf {{out}}
