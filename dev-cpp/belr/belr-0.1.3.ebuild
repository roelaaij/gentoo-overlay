# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Bellecom card library"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# TODO: run-time test for ipv6: does it need mediastreamer[ipv6]?
IUSE="tools test"

RDEPEND="net-libs/bctoolbox"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_STRICT=NO
		-DENABLE_TOOLS="$(usex tools)"
		-DENABLE_TESTS="$(usex test)"
	)

	cmake-utils_src_configure
}
