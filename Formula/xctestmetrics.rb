# Documentation: https://docs.brew.sh/Formula-Cookbook
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
class Xctestmetrics < Formula
  desc "Command-line tool that provides metrics about your project tests"
  homepage "https://github.com/serralvo/XCTestMetrics"
  url "https://github.com/serralvo/XCTestMetrics"
  version "0.0.1"
  
  depends_on :xcode => ["11.0", :build]

  def install
    system "make", "install"
  end

  test do
    swift test
  end
end