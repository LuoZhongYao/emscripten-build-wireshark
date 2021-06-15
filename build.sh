#!/bin/bash
set -e
source ~/.local/emsdk/emsdk_env.sh
sysroot=~/.local/emsdk/upstream/emscripten/cache/sysroot

function get()
{
	mkdir -p download target

	if [ ! -f download/$2 ];then
		wget $1/$2 -O download/$2
		tar xf download/$2 -C target
	fi
}

function configure()
{
	$emconfigure ./configure $*
}

function replace-host-with-target()
{
	src=$1/$2
	dst=$1/$2
	shift 2
	for pkg in $*;do
		if ! cmp $src/$pkg $dst/$pkg;then
			cp $src/$pkg $dst/$pkg
		fi
	done
}

function build()
{
	$emmake make $*
}

if [ ! -d acfa1c09522705efa5eb0541d2d00887 ];then
	git clone https://gist.github.com/acfa1c09522705efa5eb0541d2d00887.git
fi

pushd acfa1c09522705efa5eb0541d2d00887
sed -i 's:TARGET=\$SOURCE_DIR/target:TARGET=~/.local/emsdk/upstream/emscripten/cache/sysroot:g' build.sh
sed "/if cc.has_header_symbol('pthread.h', 'pthread_attr_setinheritsched')/,+2d" deps/glib/meson.build -i
chmod +x ./build.sh
./build.sh
popd

get https://gnupg.org/ftp/gcrypt/libgcrypt libgpg-error-1.42.tar.bz2
get https://gnupg.org/ftp/gcrypt/libgcrypt libassuan-2.5.5.tar.bz2
get https://gnupg.org/ftp/gcrypt/libgcrypt libgcrypt-1.9.3.tar.bz2
get https://github.com/c-ares/c-ares/releases/download/cares-1_17_1 c-ares-1.17.1.tar.gz

#(cd target/libgpg-error-1.42;
#emmake=emmake;
#emconfigure=emconfigure;
#configure --build=x86_64-redhat-linux --enable-static --disable-shared --disable-doc --prefix=$sysroot;
#sed -i src/Makefile					\
#	-e 's:\$(CPPFLAGS_FOR_BUILD) -g -I. -I\$(srcdir) -o \$@ \$(srcdir)/mkheader.c:-s NODERAWFS=1 &:g' \
#	-e 's:\./gen-posix-lock-obj >\$@:$(EMSDK_NODE) &:g'	\
#	-e 's:\./mkheader:node &:g'			\
#	-e 's:\./mkerrcodes:node &:g'			\
#	;
#build all install)
#
#(cd target/libassuan-2.5.5;
#emmake=emmake;
#emconfigure=emconfigure;
#configure --build=x86_64-redhat-linux --enable-static --disable-shared --disable-doc --prefix=$sysroot;
#sed -i src/Makefile					\
#	-e 's:\$(LDFLAGS_FOR_BUILD) -I. -I\$(srcdir) -o \$@ \$(srcdir)/mkheader.c:-s NODERAWFS=1 &:g'\
#	-e 's:\./mkheader:$(EMSDK_NODE) &:g'			\
#	;
#build all install)

# (cd target/libgcrypt-1.9.3;
# emmake=emmake;
# emconfigure=emconfigure;
# configure --build=x86_64-redhat-linux --enable-static --disable-shared --disable-doc --disable-asm --prefix=$sysroot;
# sed -i cipher/Makefile						\
# 	-e 's:\$(CPPFLAGS_FOR_BUILD)-o \$@ \$(srcdir)/gost-s-box.c:-s NODERAWFS=1 &:g'\
# 	-e 's:\./gost-s-box:$(EMSDK_NODE) &:g'				\
# 	;
# sed -i random/rndlinux.c						\
# 	-e 's:#include <sys/stat.h>:&\n#include <sys/random.h>:g'	\
# 	;
# sed -i tests/Makefile					\
# 	-e 's:^:#:g'					\
# 	-e '$aall install:'				\
# ;
# build all install)

(cd target/c-ares-1.17.1;
emmake=emmake;
emconfigure=emconfigure;
configure --build=x86_64-redhat-linux --enable-static --disable-shared --disable-doc --enable-tests --prefix=$sysroot;
build all install)
