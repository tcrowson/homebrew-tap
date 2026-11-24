# tcrowson/homebrew-tap

Mac apps by Tim Crowson, Developer ID signed and notarized by Apple.

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

## Update and uninstall

```bash
brew update && brew upgrade --cask system-basics
brew uninstall --cask system-basics          # add --zap to also remove its settings
```
