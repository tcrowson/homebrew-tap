cask "system-basics" do
  version "0.3.1"
  sha256 "91b8e2a2577d9ce70ea11f5d3f971a2ed98fea0a3ec230133897a839184e48e5"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics Plus"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics Plus.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
