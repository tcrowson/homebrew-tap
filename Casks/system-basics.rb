cask "system-basics" do
  version "0.2.0"
  sha256 "84caec36f951770d8dcbb857d3547f9533577ff6c0858e1365e935dd25d4a7e6"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics Plus"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics Plus.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
