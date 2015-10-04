class LstoreLio < Formula
  head "https://github.com/accre/lstore-lio.git"
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

  def install
    apr_paths = %W[-DCMAKE_LIBRARY_PATH=#{ENV["CMAKE_LIBRARY_PATH"]};#{Formula["apr-accre"].libexec}/lib;#{Formula["apr-util-accre"].libexec}/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].libexec}/include/apr-1
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].libexec}/include/apr-1]
    fuse_path = "-DCMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]};/usr/local/include/osxfuse"
    system "cmake", ".", fuse_path, *apr_paths, *std_cmake_args
    system "make", "install"
  end

  test do
    system "true"
  end
end
