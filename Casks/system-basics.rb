cask "system-basics" do
  version "0.3.0"
  sha256 "4a91f5bcfee4a6b1be616fce2027d7ca2a7fba01323c7fee8d53791208a2315b"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics Plus"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics Plus.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
