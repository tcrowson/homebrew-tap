# tcrowson/homebrew-tap

Mac apps by Tim Crowson, Developer ID signed and notarized by Apple. Screenshots and feature docs: **[tcrowson.github.io/homebrew-tap](https://tcrowson.github.io/homebrew-tap/)**.

| App | What it does | Needs |
| --- | --- | --- |
| [System Basics](https://tcrowson.github.io/homebrew-tap/system-basics/) | Live system graphs in a window, the menu bar and the Dock | macOS 15 |

## Install

```bash
brew trust --cask tcrowson/tap/system-basics
brew install --cask tcrowson/tap/system-basics
```

Homebrew 6 and later asks you to trust a third-party cask before installing it. To trust every app in this tap at once, use `brew trust tcrowson/tap` instead.

## Update and uninstall

```bash
brew upgrade --cask system-basics
brew uninstall --cask system-basics          # add --zap to also remove its settings
```
