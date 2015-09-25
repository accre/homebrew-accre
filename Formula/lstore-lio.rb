# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class LstoreLio < Formula
  desc ""
  homepage ""
  url "https://github.com/accre/lstore-lio.git"
  version "1.0.0"
  sha256 ""
  depends_on "cmake" => :build
  depends_on "apr-accre" => :build
  depends_on "apr-util-accre" => :build
  depends_on "zeromq"
  depends_on "czmq"
  depends_on :osxfuse
  depends_on "lstore-gop"
  depends_on "lstore-ibp"
  depends_on "lstore-toolbox"
  depends_on "libjerasure1"
  depends_on "phoebus" => :optional

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    apr_paths = %W[
                   -DAPR_LIBRARY=#{Formula["apr-accre"]}/libexec/lib
                   -DAPRUTIL_LIBRARY=#{Formula["apr-util-accre"]}/libexec/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"]}/libexec/include
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"]}/libexec/include
                   ]
    #inreplace "CMakeLists.txt", /rt pthread m dl/, "pthread m dl"
    apr_paths = %W[-DCMAKE_LIBRARY_PATH=#{ENV["CMAKE_LIBRARY_PATH"]};#{Formula["apr-accre"].libexec}/lib;#{Formula["apr-util-accre"].libexec}/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].libexec}/include/apr-1
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].libexec}/include/apr-1]
    fuse_path = "-DCMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]};/usr/local/include/osxfuse"
    system "cmake", ".", fuse_path, *apr_paths, *std_cmake_args


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
