# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

CVMFS_V=2.4.4

DESCRIPTION="free and open-source implementation of the SHAKE
extendable-output functions and SHA-3 hash functions from FIPS 202, a
variant of the of the Keccak sponge family of functions."
HOMEPAGE="https://github.com/gvanas/KeccakCodePackage"
SRC_URI="https://github.com/cvmfs/cvmfs/archive/${CVMFS_V}.tar.gz -> cvmfs-${CVMFS_V}.tar.gz"

SLOT="0"
LICENSE="public-domain BSD"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/cvmfs-cvmfs-${CVMFS_V}/externals/sha3/src"

PATCHES=( "${FILESDIR}/make-shared.patch" )

src_configure() {
	rm -f SnP-interface.h
	ln -s 64opt/SnP-interface.h SnP-interface.h
	default
}

src_compile() {
	emake CVMFS_BASE_C_FLAGS="${CFLAGS}" ARCH=64opt libsha3.so.0
}

src_install() {
	doheader 64opt/SnP-interface.h KeccakF-1600-interface.h \
			 SnP-FBWL-default.h SnP-Relaned.h KeccakHash.h \
			 KeccakSponge.h
	dolib.so libsha3.so.0
	dosym libsha3.so.0 /usr/$(get_libdir)/libsha3.so
	dodoc README LICENSE
}
