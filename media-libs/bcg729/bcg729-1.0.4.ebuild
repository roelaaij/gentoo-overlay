# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils

DESCRIPTION="encoder and decoder of the ITU G729 Annex A/B speech codec"
HOMEPAGE="https://github.com/BelledonneCommunications/bcg729"
SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~hppa ~ia64 ~ppc64 ~x86"
IUSE="static-libs"
RDEPEND="
	!media-plugins/mediastreamer-bcg729
"

src_configure() {
		local mycmakeargs=(
				-DENABLE_STATIC="$(usex static-libs)"
		)

		cmake-utils_src_configure
}
