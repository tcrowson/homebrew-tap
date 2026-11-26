cask "system-basics" do
  version "0.2.2"
  sha256 "22fca3400ac1b306a1a4dedac470b986d0ba03680d83fcabeaa1c50baead9444"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics Plus"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics Plus.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
