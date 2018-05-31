# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_PN="bcg729"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Backported G729 implementation for Linphone"
HOMEPAGE="http://www.linphone.org"
SRC_URI="https://github.com/BelledonneCommunications/${MY_PN}/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND=">=media-libs/mediastreamer-2.15.1:=[ortp]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
	)
	cmake-utils_src_configure
}
