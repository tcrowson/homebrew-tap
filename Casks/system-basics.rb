cask "system-basics" do
  version "0.1.0"
  sha256 "43a97f9e01b4150a73073881c81100fd8e1da5bc454666ea6273255717f5d160"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://github.com/tcrowson/homebrew-tap"

  depends_on macos: :sequoia

  app "System Basics.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
