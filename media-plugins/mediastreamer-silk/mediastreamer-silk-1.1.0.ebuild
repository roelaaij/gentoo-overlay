# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="mssilk"
SDK_FILE="SILK_SDK_SRC_v1.0.9.zip" # please update silk version on bumps!

inherit cmake-utils

DESCRIPTION="SILK (skype codec) implementation for Linphone"
HOMEPAGE="http://www.linphone.org"
SRC_URI="https://github.com/Distrotech/${MY_PN}/archive/${PV}.tar.gz -> ${MY_PN}-${PV}.tar.gz
		 http://www.yxplayer.net/files/${SDK_FILE}"

LICENSE="GPL-2+ Clear-BSD SILK-patent-license"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86"

RDEPEND=">=media-libs/mediastreamer-2.15.1:=[video]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}"

RESTRICT="bindist mirror" # silk license forbids distribution

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
	)
	cmake-utils_src_configure
}
