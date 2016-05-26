# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils

DESCRIPTION="CernVM-FS"
HOMEPAGE="https://cernvm.cern.ch/portal/filesystem"
SRC_URI="https://ecsft.cern.ch/dist/${PN}/${P}/source.tar.gz -> ${P}.tar.gz"

SLOT="0"

LICENSE="BSD"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux"

IUSE="-builtin-sqlite -builtin-curl -builtin-pacparser -builtin-zlib -builtin-sparsehash -builtin-leveldb -builtin-gtest -builtin-geoip -builtin-tbb"

RDEPEND="builtin-sqlite? ( dev-db/sqlite:3 )
		 builtin-curl? ( net-misc/curl )
		 builtin-pacparser? ( net-libs/pacparser )
		 builtin-zlib? ( sys-libs/zlib )
		 builtin-sparsehash? ( dev-cpp/sparsehash )
		 builtin-leveldb? ( dev-libs/leveldb )
		 builtin-gtest? ( dev-cpp/gtest )
		 builtin-tbb? ( dev-cpp/tbb )
		 builtin-geoip? ( dev-libs/geoip dev-python/geoip-python )
		 >=sys-fs/fuse-2.9.4
		 >=net-dns/c-ares-1.10.0-r1"

DEPEND="${RDEPEND}"

DOCS=( ChangeLog README )

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use builtin-sqlite SQLITE3_BUILTIN)
		$(cmake-utils_use builtin-curl LIBCURL_BUILTIN)
		$(cmake-utils_use builtin-pacparser PACPARSER_BUILTIN)
		$(cmake-utils_use builtin-zlib ZLIB_BUILTIN)
		$(cmake-utils_use builtin-sparsehash SPARSEHASH_BUILTIN)
		$(cmake-utils_use builtin-leveldb LEVELDB_BUILTIN)
		$(cmake-utils_use builtin-gtest GOOGLETEST_BUILTIN)
		$(cmake-utils_use builtin-geoip GEOIP_BUILTIN)
		$(cmake-utils_use builtin-tbb TBB_PRIVATE_LIB)
	)
	cmake-utils_src_configure
}
