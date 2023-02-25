# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="simple, modern libpng alternative"
HOMEPAGE="https://libspng.org"
SRC_URI="https://github.com/randy408/libspng/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv x86"

IUSE="static-libs"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

RESTRICT="test"

src_prepare() {
	sed -e "/TARGETS.*DESTINATION/s,lib,$(get_libdir)," \
		-i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DSPNG_STATIC=$(usex static-libs)
		-DBUILD_EXAMPLES=OFF
	)
	cmake_src_configure
}
