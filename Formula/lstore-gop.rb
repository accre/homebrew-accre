# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class LstoreGop < Formula
  desc ""
  homepage ""
  url "https://github.com/accre/lstore-gop.git", :branch => "redmine_pre-alok"
  version "1.0.0"
  sha256 ""

  depends_on "cmake" => :build
  depends_on "apr-accre" => :build
  depends_on "apr-util-accre" => :build
  depends_on "zeromq"
  depends_on "czmq"
  depends_on "zlib"
  depends_on "lstore-toolbox"
  depends_on "phoebus" => :optional

  #patch :DATA

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    apr_paths = %W[
                   -DAPR_LIBRARY=#{Formula["apr-accre"].opt_prefix}/libexec/lib
                   -DAPRUTIL_LIBRARY=#{Formula["apr-util-accre"].opt_prefix}/libexec/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].opt_prefix}/libexec/include
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].opt_prefix}/libexec/include
                   ]
    inreplace "CMakeLists.txt", /pthread m dl rt/, "pthread m dl"
    #inreplace "CMakeLists.txt", /ADD_EXECUTABLE\(rr_mq_test/, "#ADD_EXECUTABLE(rr_mq_test"
    #inreplace "CMakeLists.txt", /SET_TARGET_PROPERTIES\(rr_mq_test/, "#SET_TARGET_PROPERTIES(rr_mq_test"
    #inreplace "CMakeLists.txt", /TARGET_LINK_LIBRARIES\(rr_mq_test/, "#TARGET_LINK_LIBRARIES(rr_mq_test"
    #inreplace "rr_mq_client.c", /#include <sys\/eventfd\.h>/, ""
    #inreplace "rr_mq_server.c", /#include <sys\/eventfd\.h>/, ""
    #inreplace "rr_mq_worker.c", /#include <sys\/eventfd\.h>/, ""
    apr_paths = %W[-DCMAKE_LIBRARY_PATH=#{ENV["CMAKE_LIBRARY_PATH"]};#{Formula["apr-accre"].libexec}/lib;#{Formula["apr-util-accre"].libexec}/lib
                   -DAPR_INCLUDE_DIR=#{Formula["apr-accre"].libexec}/include/apr-1
                   -DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util-accre"].libexec}/include/apr-1]
    inreplace "mq_portal.h", /typedef zmq_event_t mq_event_t;/, ""
    system "cmake", ".",*apr_paths, *std_cmake_args
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
__END__
diff --git a/rr_mq_server.c b/rr_mq_server.c
index dc63806..4a6ed7e 100644
--- a/rr_mq_server.c
+++ b/rr_mq_server.c
@@ -280,7 +280,7 @@ void *queue_checker(apr_thread_t *thread, void *arg) {
         sleep(1);
 
         if(complete != 0)
-            return;
+            return NULL;
 
         log_printf(15, "SERVER: Checking processing queue...\n");
         int n_messages;

