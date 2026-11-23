# tcrowson/homebrew-tap

Mac apps by Tim Crowson, Developer ID signed and notarized.

## Install

```bash
brew tap tcrowson/tap
brew trust --cask tcrowson/tap/system-basics
brew install --cask system-basics
```

Homebrew 6 and later asks you to trust a third-party tap's cask before installing it.

| Cask | App | Needs |
| --- | --- | --- |
| `system-basics` | System Basics: live system graphs in a window, the menu bar and the Dock | macOS 15 |

## Releasing (maintainer)

Built apps are attached to releases on this repository (tag `<cask>-<version>`), so app source repositories can stay private.

One-time setup:

1. A **Developer ID Application** certificate in the login keychain (Xcode > Settings > Accounts > Manage Certificates > +).
2. Notary credentials in the keychain, with an app-specific password from account.apple.com:
   `xcrun notarytool store-credentials notary --apple-id <apple id> --team-id <team id>`
3. `gh auth login`.

Per app: add `Casks/<cask>.rb` (copy `system-basics.rb`), and a `release` target in the app's Makefile:

```make
release:
	$(HOME)/dev/homebrew-tap/scripts/release-app.sh --project Foo.xcodeproj --scheme Foo --app "Foo.app" --cask foo
```

Per release: bump `MARKETING_VERSION`, then `make release`. The script archives, exports with Developer ID, notarizes, staples, checks Gatekeeper, zips, asks before publishing, then creates the release and pushes the updated cask. `--check` only verifies the setup.
