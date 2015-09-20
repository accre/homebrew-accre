# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class AprAccre < Formula
  desc "ACCRE-Modified Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-1.5.1.tar.bz2"
  sha256 "e94abe431d4da48425fcccdb27b469bd0f8151488f82e5630a56f26590e198ac"
  option :universal

  patch do
      url "https://github.com/accre/lstore-release/raw/master/tarballs/apr.patch"
      sha256 "b42a4423c9f5d2fad2154d8a8728c757eb0487378ad77e6a2e0b38c9dec485c5"
  end
  
  def install
    ENV.universal_binary if build.universal?

    # https://bz.apache.org/bugzilla/show_bug.cgi?id=57359
    # The internal libtool throws an enormous strop if we don't do...
    ENV.deparallelize


    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/apr-ACCRE-1-config", "--link-libtool", "--libs"
  end

end
