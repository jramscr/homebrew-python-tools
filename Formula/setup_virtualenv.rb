class SetupVirtualenv < Formula
  desc "Tool to setup and delete Python virtual environments easily"
  homepage "https://github.com/YOUR_GITHUB_USERNAME/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.0.0.tar.gz"
  version "1.0.0"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
