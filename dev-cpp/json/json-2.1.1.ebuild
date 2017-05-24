# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="https://github.com/nlohmann/json"
SRC_URI="https://github.com/nlohmann/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 sparc x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	eapply "${FILESDIR}"/locations.patch
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBuildTests=OFF
		-DJSON_INCLUDE_DESTINATION=include
		-DJSON_CONFIG_DESTINATION=share/cmake/modules
	)
	cmake-utils_src_configure
}
