class AprUtilAccre < Formula
  desc "ACCRE-modified Companion library to apr, the Apache Portable Runtime library"
  homepage "https://www.lstore.org/"
  head "https://github.com/accre/lstore-apr-util-accre.git", \
                                                :branch => "accre-fork"

  option :universal

  depends_on "apr-accre"
  depends_on "openssl"
  depends_on "postgresql" => :optional

  def install
    ENV.universal_binary if build.universal?

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    args = %W[
      --prefix=#{libexec}
      --with-apr=#{Formula["apr-accre"].opt_prefix}/bin/apr-ACCRE-1-config
      --with-openssl=#{Formula["openssl"].opt_prefix}
    ]

    args << "--with-pgsql=#{Formula["postgresql"].opt_prefix}" if build.with? "postgresql"

    system "./configure", *args
    system "make"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/apu-ACCRE-1-config", "--link-libtool", "--libs"
  end
end
