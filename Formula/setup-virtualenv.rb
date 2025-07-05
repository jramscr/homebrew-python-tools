class SetupVirtualenv < Formula
  desc "Centralized Python virtual environment management with automatic configuration inference"
  homepage "https://github.com/jramscr/homebrew-python-tools"
  url "https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v1.1.3.tar.gz"
  version "1.1.4"
  sha256 "04001ce12b461f0ba623cd2171c5962b477b77e15a8e84ef51eae4a197269d76"

  def install
    bin.install "bin/setup-virtualenv"
    bin.install "bin/delete-virtualenv"
  end
end
