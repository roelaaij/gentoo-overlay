# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3 cmake

DESCRIPTION="C++ range v3 library"
HOMEPAGE="https://github.com/ericniebler/range-v3"

EGIT_REPO_URI="https://github.com/ericniebler/range-v3"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS=""
IUSE=""

src_prepare() {
	cmake_src_prepare

	# remove tests and examples
	sed -i -e '/add_subdirectory(test)/d' -e '/add_subdirectory(example)/d' -e '/add_subdirectory(perf)/d' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DRANGE_V3_EXAMPLES=OFF
		-DRANGE_V3_HEADER_CHECKS=OFF
		-DRANGE_V3_PERF=OFF
		-DRANGE_V3_TESTS=OFF
		-DRANGES_BUILD_CALENDAR_EXAMPLE=OFF
		-DRANGES_NATIVE=OFF
	)

	cmake_src_configure
}
