# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class LstoreToolbox < Formula
  desc "Toolbox of commonly used functions at ACCRE"
  homepage "https://github.com/accre/lstore-toolbox"
  url "https://github.com/accre/lstore-toolbox.git"
  version "1.0.0"
  sha256 ""

  depends_on "cmake" => :build
  depends_on "apr-accre" => :build
  depends_on "apr-util-accre" => :build
  depends_on "zeromq"
  depends_on "czmq"
  depends_on "phoebus" => :optional
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
 # #{Formula["apr-accre"].opt_prefix}
                   #{Formula["apr-accre"].libexec}
    inreplace "CMakeLists.txt", /rt pthread m dl/, "pthread m dl"
    apr_paths = %W[-DCMAKE_LIBRARY_PATH=#{ENV["CMAKE_LIBRARY_PATH"]};#{Formula["apr-accre"].libexec}/lib;#{Formula["apr-util-accre"].libexec}/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].libexec}/include/apr-1
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].libexec}/include/apr-1]
    system "cmake", ".", *apr_paths, *std_cmake_args
    system "make", "install"  # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test libaccre-toolbox`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
