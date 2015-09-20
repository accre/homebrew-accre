# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Libjerasure1 < Formula
  desc ""
  homepage ""
  url "https://github.com/tsuraan/Jerasure.git", :branch => "v1"
  version "1"
  sha256 ""

  depends_on :x11 # if your formula requires any X11/XQuartz components

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    # Remove unrecognized options if warned by configure
    #system "./configure", "--disable-debug",
    #                      "--disable-dependency-tracking",
    #                      "--disable-silent-rules",
    #                      "--prefix=#{prefix}"

    inreplace "Makefile", /PREFIX=\${HOME}\/local/, ""
    inreplace "src/Makefile", /-soname/, "-install_name"
    inreplace "src/Makefile", /libJerasure.so.0/, "libJerasure.0.dylib"
    inreplace "src/Makefile", /libJerasure.so/, "libJerasure.dylib"
    inreplace "Makefile", /libJerasure.so/, "libJerasure.dylib"
    system "mkdir", "-p", "#{prefix}/lib",  "#{prefix}/bin",  "#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"   
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test libjerasure1`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
