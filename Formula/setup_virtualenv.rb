class SetupVirtualenv < Formula
  desc "Centralized Python virtual environment management with automatic configuration inference"
  homepage "https://github.com/jramscr/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.1.0.tar.gz"
  version "1.1.3"
  sha256 "e9072317683fa7d7c5bbbcfb1fbf628f4dd2411eb5c49167b6591cdeea266105"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
