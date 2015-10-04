class LstoreToolbox < Formula
  desc "Toolbox of commonly used functions at ACCRE"
  homepage "https://github.com/accre/lstore-toolbox"
  head "https://github.com/accre/lstore-toolbox.git"

  depends_on "cmake" => :build
  depends_on "apr-accre" => :build
  depends_on "apr-util-accre" => :build
  depends_on "zeromq"
  depends_on "czmq"
  def install
    # We keep our own APR, help brew find it.
    apr_paths = %W[-DCMAKE_LIBRARY_PATH=#{ENV["CMAKE_LIBRARY_PATH"]};#{Formula["apr-accre"].libexec}/lib;#{Formula["apr-util-accre"].libexec}/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].libexec}/include/apr-1
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].libexec}/include/apr-1]
    system "cmake", ".", *apr_paths, *std_cmake_args
    system "make", "install"    
  end

  test do
    system "true"
  end
end
