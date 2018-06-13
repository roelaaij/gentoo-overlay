# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Bellecom implementation of ZRTP protocol"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/bzrtp/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test +cache"

RDEPEND="cache? ( dev-db/sqlite )"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_ZIDCACHE="$(usex cache)"
		-DENABLE_STRICT=YES
		-DENABLE_TESTS="$(usex test)"
	)

	cmake-utils_src_configure
}
