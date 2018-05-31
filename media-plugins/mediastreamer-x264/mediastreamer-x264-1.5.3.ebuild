# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_P="msx264-${PV}"

DESCRIPTION="mediastreamer plugin: add H264 support"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/Distrotech/msx264/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="libav"

RDEPEND=">=media-libs/mediastreamer-2.15.1:=[video]
	>=media-libs/x264-0.0.20160712:=
	libav? ( media-video/libav:0= )
	!libav? ( media-video/ffmpeg:0= )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
	)
	cmake-utils_src_configure
}
