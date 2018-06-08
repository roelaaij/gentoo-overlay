# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit pax-utils cmake-utils

MY_PN="${PN//-/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Video softphone based on the SIP protocol"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="http://www.linphone.org/releases/sources/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=" dbus "

RDEPEND="
	>=net-voip/linphone-3.12.0[cxx]
	>=net-libs/bctoolbox-0.5.1
	>=dev-cpp/belcard-1.0.2
	>=dev-cpp/belr-0.1.3
	>=dev-qt/qtcore-5.9.1
	>=dev-qt/qtgui-5.9.1
	>=dev-qt/qtwidgets-5.9.1
	>=dev-qt/qtquickcontrols2-5.9.1
	>=dev-qt/qtsvg-5.9.1
	>=dev-qt/linguist-tools-5.9.1
	>=dev-qt/qtconcurrent-5.9.1
	>=dev-qt/qtnetwork-5.9.1
	>=dev-qt/qttest-5.9.1
	dbus? ( >=dev-qt/qtdbus-5.9.1 )
"
DEPEND="${RDEPEND}
"

IUSE_LINGUAS=" fr en"
IUSE="${IUSE}${IUSE_LINGUAS// / linguas_}"

PATCHES="${FILESDIR}/no-git.patch
		 ${FILESDIR}/${PN}-5.10.patch"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	strip-linguas ${IUSE_LINGUAS}
}

src_prepare() {
	sed -i -e "s/LINPHONE_QT_GIT_VERSION/\"${PV}\"/g" "${S}/src/app/AppController.cpp" || die
	sed -i -e "s/Exec=linphone/Exec=${PN}/g" "${S}/assets/linphone.desktop" || die
	mv "${S}/assets/linphone.desktop" "${S}/assets/${PN}.desktop" || die
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_DBUS="$(usex dbus)"
		-DENABLE_UPDATE_CHECK=NO
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc CHANGELOG.md README.md
	pax-mark m "${ED%/}/usr/bin/linphone-qt"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
