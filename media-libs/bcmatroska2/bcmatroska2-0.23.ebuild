# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Bellecom matroska library"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://www.linphone.org/releases/sources/bcmatroska2/bcmatroska2-0.23.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DCONFIG_DEBUGCHECKS=NO
	)

	cmake-utils_src_configure
}
