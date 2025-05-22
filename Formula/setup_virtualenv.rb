class SetupVirtualenv < Formula
  desc "Tool to setup and delete Python virtual environments easily"
  homepage "https://github.com/jramscr/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.0.2.tar.gz"
  version "1.0.2"
  sha256 "e9072317683fa7d7c5bbbcfb1fbf628f4dd2411eb5c49167b6591cdeea266105"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
