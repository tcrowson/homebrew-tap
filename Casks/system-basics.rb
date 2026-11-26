cask "system-basics" do
  version "0.2.1"
  sha256 "b642d9ed4f2a3e59cbcb762416e09c0fa9697b22f3bcf8bb570bc77c8a7efd1a"

  url "https://github.com/tcrowson/homebrew-tap/releases/download/system-basics-#{version}/system-basics-#{version}.zip"
  name "System Basics Plus"
  desc "Live CPU, GPU, memory, network and temperature graphs"
  homepage "https://tcrowson.github.io/homebrew-tap/system-basics/"

  depends_on macos: :sequoia

  app "System Basics Plus.app"

  zap trash: "~/Library/Preferences/com.tcrowson.systembasics.plist"
end
