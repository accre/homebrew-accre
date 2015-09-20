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
  depends_on "zlib"
  depends_on :osxfuse
  depends_on "lstore-gop"
  depends_on "lstore-ibp"
  depends_on "lstore-toolbox"
  depends_on "libjerasure1"
  depends_on "phoebus" => :optional

  #patch :DATA
  patch :p1, 'diff --git a/.gitignore b/.gitignore
index 50de23a..6086184 100644
--- a/.gitignore
+++ b/.gitignore
@@ -49,6 +49,7 @@ lio_server
 
 #These are generated via cmake using the *.in variants
 lio_client_version.c
+config.h
 
 #Skip edits
 *~
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 4ca7f66..a20f17f 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -35,7 +35,15 @@ find_package(ZMQ REQUIRED)
 find_package(CZMQ REQUIRED)
 find_package(FUSE REQUIRED)
 find_package(Zlib REQUIRED)
-find_package(XATTR REQUIRED)
+find_package(XATTR)
+SET(XATTR_LIBRARY "")
+SET(XATTR_INCLUDE_DIR "")
+SET(XATTR_FOUND "")
+
+# check for xattr
+configure_file("${PROJECT_SOURCE_DIR}/config.h.in" "${PROJECT_SOURCE_DIR}/config.h")
+check_include_file(attr/xattr.h HAVE_ATTR_XATTR_H)
+check_include_file(sys/xattr.h HAVE_SYS_XATTR_H)
 
 set(CMAKE_C_FLAGS_DEBUG "${CMAKE_REQUIRED_FLAGS} -O0 -Wall -g -DHAVE_CONFIG_H -DLINUX=2 -D_REENTRANT -D_GNU_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 ${XATTR_FOUND}" )
 set(CMAKE_C_FLAGS_RELEASE "-O ${CMAKE_REQUIRED_FLAGS} -DHAVE_CONFIG_H -DLINUX=2 -D_REENTRANT -D_GNU_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 ${XATTR_FOUND}" )
diff --git a/cmake/FindFUSE.cmake b/cmake/FindFUSE.cmake
index a652778..3b655e1 100644
--- a/cmake/FindFUSE.cmake
+++ b/cmake/FindFUSE.cmake
@@ -1,38 +1,46 @@
-# -*- cmake -*-
-
-# - Find FUSE libraries and includes
+# Find the FUSE includes and library
 #
-# This module defines
-#    FUSE_INCLUDE_DIR - where to find header files
-#    FUSE_LIBRARIES - the libraries needed to use FUSE.
-#    FUSE_FOUND - If false didn\'t find FUSE
-
-# Find the include path
-find_path(fuse_inc fuse/fuse_lowlevel.h)
-
-if (fuse_inc)
-   find_path(FUSE_INCLUDE_DIR fuse_lowlevel.h ${fuse_inc}/fuse)
-else (fuse_inc)
-   find_path(FUSE_INCLUDE_DIR fuse_lowlevel.h)
-endif (fuse_inc)
+#  FUSE_INCLUDE_DIR - where to find fuse.h, etc.
+#  FUSE_LIBRARIES   - List of libraries when using FUSE.
+#  FUSE_FOUND       - True if FUSE lib is found.
+
+# check if already in cache, be silent
+IF (FUSE_INCLUDE_DIR)
+        SET (FUSE_FIND_QUIETLY TRUE)
+ENDIF (FUSE_INCLUDE_DIR)
+
+# find includes
+FIND_PATH (FUSE_INCLUDE_DIR fuse.h
+        /usr/local/include/osxfuse
+        /usr/local/include
+        /usr/include
+)
 
-find_library(FUSE_LIBRARY NAMES fuse)
+# find lib
+if (APPLE)
+    SET(FUSE_NAMES libosxfuse.dylib fuse)
+else (APPLE)
+    SET(FUSE_NAMES fuse)
+endif (APPLE)
+FIND_LIBRARY(FUSE_LIBRARIES
+        NAMES ${FUSE_NAMES}
+        PATHS /lib64 /lib /usr/lib64 /usr/lib /usr/local/lib64 /usr/local/lib
+)
+SET(FUSE_LIBRARY ${FUSE_LIBRARIES})
 
 if (FUSE_LIBRARY AND FUSE_INCLUDE_DIR)
-    SET(FUSE_FOUND "YES")
+    SET(FUSE_FOUND 1)
 endif (FUSE_LIBRARY AND FUSE_INCLUDE_DIR)
 
-
 if (FUSE_FOUND)
    message(STATUS "Found FUSE: ${FUSE_LIBRARY} ${FUSE_INCLUDE_DIR}")
 else (FUSE_FOUND)
    message(STATUS "Could not find FUSE library")
 endif (FUSE_FOUND)
 
+include ("FindPackageHandleStandardArgs")
+find_package_handle_standard_args ("FUSE" DEFAULT_MSG
+    FUSE_INCLUDE_DIR FUSE_LIBRARIES)
 
-MARK_AS_ADVANCED(
-  FUSE_LIBRARY
-  FUSE_INCLUDE_DIR
-  FUSE_FOUND
-)
+mark_as_advanced (FUSE_INCLUDE_DIR FUSE_LIBRARIES)
 
diff --git a/config.h.in b/config.h.in
new file mode 100644
index 0000000..60e67d4
--- /dev/null
+++ b/config.h.in
@@ -0,0 +1,7 @@
+# Autoconfigured!
+
+#cmakedefine HAVE_ATTR_XATTR_H
+#cmakedefine HAVE_SYS_XATTR_H
+#if defined(HAVE_SYS_XATTR_H) | defined(HAVE_ATTR_XATTR_H)
+#define HAVE_XATTR
+#endif
'
  patch :p1, 'diff --git a/lio_fuse_core.c b/lio_fuse_core.c
index 74426bc..117b903 100644
--- a/lio_fuse_core.c
+++ b/lio_fuse_core.c
@@ -28,10 +28,16 @@ http://www.accre.vanderbilt.edu
 */
 
 #define _log_module_index 212
+#include "config.h"
+#if defined(HAVE_SYS_XATTR_H)
+#include <sys/xattr.h>
+#elif defined(HAVE_ATTR_XATTR_H)
+#include <attr/xattr.h>
+#endif
+
 
 #include <assert.h>
 #include <sys/types.h>
-#include <attr/xattr.h>
 #include <sys/stat.h>
 #include <unistd.h>
 #include <math.h>
'

  patch :p1, 'diff --git a/lio_fuse.h b/lio_fuse.h
index a4c91ae..22fae2f 100644
--- a/lio_fuse.h
+++ b/lio_fuse.h
@@ -159,8 +159,10 @@ int lfs_read_ex(const char *fname, int n_iov, ex_iovec_t *iov, tbuffer_t *buffer
 int lfs_write(const char *fname, const char *buf, size_t size, off_t off, struct fuse_file_info *fi);
 int lfs_writev(const char *fname, iovec_t *iov, int n_iov, size_t size, off_t off, struct fuse_file_info *fi);
 int lfs_write_ex(const char *fname, int n_iov, ex_iovec_t *iov, tbuffer_t *buffer, ex_off_t boff, struct fuse_file_info *fi);
+#if defined(HAVE_XATTR)
 int lfs_setxattr_real(const char *fname, const char *name, const char *fval, size_t size, int flags, lio_fuse_t *lfs);
 int lfs_getxattr_real(const char *fname, const char *name, char *buf, size_t size, lio_fuse_t *lfs);
+#endif
 int lfs_unlink_real(const char *fname, lio_fuse_t *lfs);
 int lfs_opendir_real(const char *fname, struct fuse_file_info *fi, lio_fuse_t *lfs);
 int lfs_readdir_real(const char *dname, void *buf, fuse_fill_dir_t filler, off_t off, struct fuse_file_info *fi, lio_fuse_t * lfs);
diff --git a/lio_fuse_core.c b/lio_fuse_core.c
index 117b903..17487eb 100644
--- a/lio_fuse_core.c
+++ b/lio_fuse_core.c
@@ -2299,7 +2299,7 @@ if (inode == NULL) log_printf(1, "ERROR missing inode fname=%s\n", fname);
 // lfs_listxattr - Lists the extended attributes
 //    These are currently defined as the user.* attributes
 //*****************************************************************
-
+#if defined(HAVE_XATTR)
 int lfs_listxattr(const char *fname, char *list, size_t size)
 {
   char *buf, *key, *val;
@@ -2395,7 +2395,7 @@ log_printf(15, "ERANGE bpos=%d buf=%s\n", bpos, buf);
 
   return(bpos);
 }
-
+#endif // HAVE XATTR
 //*****************************************************************
 // lfs_set_tape_attr - Disburse the tape attribute
 //*****************************************************************
@@ -2621,6 +2621,7 @@ void lfs_attr_free(list_data_t *obj)
 //*****************************************************************
 // lfs_getxattr - Gets a extended attributes
 //*****************************************************************
+#if defined(HAVE_XATTR)
 int lfs_getxattr(const char *fname, const char *name, char *buf, size_t size) {
     lio_fuse_t *lfs;
     struct fuse_context *ctx;
@@ -2750,7 +2751,9 @@ log_printf(1, "ADDING fname=%s aname=%s p=%p v_size=%d df=%lf dt_query=%lf\n", f
 
   return(v_size);
 }
+#endif // defined(HAVE_XATTR)
 
+#if defined(HAVE_XATTR)
 //*****************************************************************
 // lfs_setxattr - Sets a extended attribute
 //*****************************************************************
@@ -2894,6 +2897,7 @@ log_printf(15, "REMOVING fname=%s aname=%s\n", fname, aname);
 
   return(0);
 }
+#endif // HAVE_XATTR
 
 //*************************************************************************
 // lfs_hardlink - Creates a hardlink to an existing file
'

  patch :p1, 'diff --git a/config.h.in b/config.h.in
index 60e67d4..cbae940 100644
--- a/config.h.in
+++ b/config.h.in
@@ -5,3 +5,11 @@
 #if defined(HAVE_SYS_XATTR_H) | defined(HAVE_ATTR_XATTR_H)
 #define HAVE_XATTR
 #endif
+
+#if !defined(EBADE)
+#define EBADE 50
+#endif
+
+#if !defined(EREMOTEIO)
+#define EREMOTEIO 140
+#endif
'

  patch :p1, 'diff --git a/CMakeLists.txt b/CMakeLists.txt
index a20f17f..408cdef 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -54,7 +54,7 @@ include_directories(${OPENSSL_INCLUDE_DIR} ${APR_INCLUDE_DIR} ${APRUTIL_INCLUDE_
    ${CZMQ_INCLUDE_DIR} ${XATTR_INCLUDE_DIR} )
 
 SET(LIBS ${LIBS} ${IBP_LIBRARY} ${GOP_LIBRARY} ${CZMQ_LIBRARY} ${TOOLBOX_LIBRARY} ${JERASURE_LIBRARY} ${OPENSSL_LIBRARIES} ${CRYPTO_LIBRARIES} 
-   ${APR_LIBRARY} ${APRUTIL_LIBRARY} ${ZMQ_LIBRARY} ${FUSE_LIBRARY} ${ZLIB_LIBRARY} ${XATTR_LIBRARY} pthread m dl rt)
+   ${APR_LIBRARY} ${APRUTIL_LIBRARY} ${ZMQ_LIBRARY} ${FUSE_LIBRARY} ${ZLIB_LIBRARY} ${XATTR_LIBRARY} pthread m dl)
 
 #Make the version file
 set(LIO_CLIENT_VERSION "lio_client: v1.0.0")
@@ -109,16 +109,19 @@ set(LIO_OBJS
 
 set(LIBLIO_TRACE_OBJS liblio_trace.c )
 
+if (NOT APPLE)
 ADD_LIBRARY( lio_trace SHARED ${LIBLIO_TRACE_OBJS})
+endif (NOT APPLE)
 ADD_LIBRARY( lio SHARED ${LIO_OBJS})
 ADD_LIBRARY( lio-static STATIC ${LIO_OBJS})
 SET_TARGET_PROPERTIES( lio-static PROPERTIES OUTPUT_NAME "lio" )
 SET_TARGET_PROPERTIES(lio PROPERTIES CLEAN_DIRECT_OUTPUT 1)
 SET_TARGET_PROPERTIES(lio-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
 
+if (NOT APPLE)
 ADD_LIBRARY(dynfile SHARED segment_dynfile.c )
 SET_TARGET_PROPERTIES(dynfile PROPERTIES CLEAN_DIRECT_OUTPUT 1)
-
+endif (NOT APPLE)
 set(LIO_EXE 
     mk_linear ex_load ex_get ex_put ex_inspect ex_clone ex_rw_test log_test rs_test os_test os_fsck
     lio_touch lio_mkdir lio_rmdir lio_rm lio_ln lio_find lio_ls lio_du lio_setattr lio_getattr lio_mv lio_cp
diff --git a/config.h.in b/config.h.in
index cbae940..0132529 100644
--- a/config.h.in
+++ b/config.h.in
@@ -1,4 +1,4 @@
-# Autoconfigured!
+// This file is Autoconfigured!
 
 #cmakedefine HAVE_ATTR_XATTR_H
 #cmakedefine HAVE_SYS_XATTR_H
'
  patch :p1, 'diff --git a/erasure_tools.c b/erasure_tools.c
index c1c8545..5f25958 100644
--- a/erasure_tools.c
+++ b/erasure_tools.c
@@ -36,7 +36,7 @@ http://www.accre.vanderbilt.edu
 #include "cauchy.h"
 #include "liberation.h"
 #include "reed_sol.h"
-#include "jerasure.h"
+#include <jerasure.h>
 #include "raid4.h"
 #include "erasure_tools.h"
 #include "log.h"
'
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
    system "exit", "1"
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
__END__
diff --git a/cmake/FindFUSE.cmake b/cmake/FindFUSE.cmake
index a652778..3b655e1 100644
--- a/cmake/FindFUSE.cmake
+++ b/cmake/FindFUSE.cmake
@@ -1,38 +1,46 @@
-# -*- cmake -*-
-
-# - Find FUSE libraries and includes
+# Find the FUSE includes and library
 #
-# This module defines
-#    FUSE_INCLUDE_DIR - where to find header files
-#    FUSE_LIBRARIES - the libraries needed to use FUSE.
-#    FUSE_FOUND - If false didn't find FUSE
-
-# Find the include path
-find_path(fuse_inc fuse/fuse_lowlevel.h)
-
-if (fuse_inc)
-   find_path(FUSE_INCLUDE_DIR fuse_lowlevel.h ${fuse_inc}/fuse)
-else (fuse_inc)
-   find_path(FUSE_INCLUDE_DIR fuse_lowlevel.h)
-endif (fuse_inc)
+#  FUSE_INCLUDE_DIR - where to find fuse.h, etc.
+#  FUSE_LIBRARIES   - List of libraries when using FUSE.
+#  FUSE_FOUND       - True if FUSE lib is found.
+
+# check if already in cache, be silent
+IF (FUSE_INCLUDE_DIR)
+        SET (FUSE_FIND_QUIETLY TRUE)
+ENDIF (FUSE_INCLUDE_DIR)
+
+# find includes
+FIND_PATH (FUSE_INCLUDE_DIR fuse.h
+        /usr/local/include/osxfuse
+        /usr/local/include
+        /usr/include
+)
 
-find_library(FUSE_LIBRARY NAMES fuse)
+# find lib
+if (APPLE)
+    SET(FUSE_NAMES libosxfuse.dylib fuse)
+else (APPLE)
+    SET(FUSE_NAMES fuse)
+endif (APPLE)
+FIND_LIBRARY(FUSE_LIBRARIES
+        NAMES ${FUSE_NAMES}
+        PATHS /lib64 /lib /usr/lib64 /usr/lib /usr/local/lib64 /usr/local/lib
+)
+SET(FUSE_LIBRARY ${FUSE_LIBRARIES})
 
 if (FUSE_LIBRARY AND FUSE_INCLUDE_DIR)
-    SET(FUSE_FOUND "YES")
+    SET(FUSE_FOUND 1)
 endif (FUSE_LIBRARY AND FUSE_INCLUDE_DIR)
 
-
 if (FUSE_FOUND)
    message(STATUS "Found FUSE: ${FUSE_LIBRARY} ${FUSE_INCLUDE_DIR}")
 else (FUSE_FOUND)
    message(STATUS "Could not find FUSE library")
 endif (FUSE_FOUND)
 
+include ("FindPackageHandleStandardArgs")
+find_package_handle_standard_args ("FUSE" DEFAULT_MSG
+    FUSE_INCLUDE_DIR FUSE_LIBRARIES)
 
-MARK_AS_ADVANCED(
-  FUSE_LIBRARY
-  FUSE_INCLUDE_DIR
-  FUSE_FOUND
-)
+mark_as_advanced (FUSE_INCLUDE_DIR FUSE_LIBRARIES)
 

