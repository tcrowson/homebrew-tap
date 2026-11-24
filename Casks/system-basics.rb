cask "system-basics" do
  version "0.1.1"
  sha256 "5d933bb0eac933f1838cd8118c3bde4b6f6f81d15ed8cf6056570b0e900f60a5"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
