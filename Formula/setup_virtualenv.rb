class SetupVirtualenv < Formula
  desc "Tool to setup and delete Python virtual environments easily"
  homepage "https://github.com/YOUR_GITHUB_USERNAME/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.0.1.tar.gz"
  version "1.0.1"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
