class AprAccre < Formula
  desc "ACCRE-Modified Apache Portable Runtime library"
  homepage "https://www.lstore.org/"
  head "https://github.com/accre/lstore-apr-accre.git", \
                                                :branch => "accre-fork"
  option :universal

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
