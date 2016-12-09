# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit git-r3 eutils cmake-utils

DESCRIPTION="C++ range v3 library"
HOMEPAGE="https://github.com/ericniebler/range-v3"

EGIT_REPO_URI="https://github.com/ericniebler/range-v3"

LICENSE="BSL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="|| ( >=sys-devel/gcc-4.9.0 >=sys-devel/clang-3.4.0 )"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	# remove tests and examples
	sed -i -e '/add_subdirectory(test)/d' -e '/add_subdirectory(example)/d' -e '/add_subdirectory(perf)/d' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DRANGE_V3_NO_HEADER_CHECK=ON
	)

	cmake-utils_src_configure
}
