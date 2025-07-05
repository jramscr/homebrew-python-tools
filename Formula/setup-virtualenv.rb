class SetupVirtualenv < Formula
  desc "Centralized Python virtual environment management with automatic configuration inference"
  homepage "https://github.com/jramscr/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.1.3.tar.gz"
  version "1.1.4"
  sha256 "21d7b3a5f3320c7e083454a2046d4e0c5df9da1f22e3cf6de7847b596324077c"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
