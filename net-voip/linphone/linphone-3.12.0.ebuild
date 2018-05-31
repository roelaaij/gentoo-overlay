# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib pax-utils versionator cmake-utils

DESCRIPTION="Video softphone based on the SIP protocol"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="http://www.linphone.org/releases/sources/linphone/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# TODO: run-time test for ipv6: does it need mediastreamer[ipv6]?
IUSE="assistant cxx ncurses doc gtk libnotify nls sqlite ssl tools video
	  ldap lime test vcard upnp ipv6 gsm-nonstandard tunnel"

RDEPEND="
	>=media-libs/mediastreamer-2.15.1[upnp?,video?]
	>=net-libs/libeXosip-4.0.0
	>=net-libs/libosip-4.0.0
	>=net-libs/ortp-0.22.0
	>=net-libs/bctoolbox-0.5.1
	>=net-voip/belle-sip-1.6.1[tunnel?]
	cxx? ( app-doc/doxygen
		   dev-python/pystache )
	doc? ( app-doc/doxygen
		   dev-python/pystache )
	ldap? ( >=net-nds/openldap-2.4.44 )
	virtual/udev
	gtk? (
		dev-libs/glib:2
		>=gnome-base/libglade-2.4.0:2.0
		>=x11-libs/gtk+-2.4.0:2
		assistant? ( >=net-libs/libsoup-2.26 )
		libnotify? ( x11-libs/libnotify )
	)
	gsm-nonstandard? ( >=media-libs/mediastreamer-2.15.1[gsm] )
	ncurses? (
		sys-libs/readline:0
		sys-libs/ncurses
	)
	sqlite? ( dev-db/sqlite:3 )
	ssl? ( dev-libs/openssl:0 )
	tools? ( dev-libs/libxml2 )
	upnp? ( net-libs/libupnp )
	video? ( >=media-libs/mediastreamer-2.15.1[v4l] )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-text/sgmltools-lite )
	nls? ( dev-util/intltool )
"

IUSE_LINGUAS=" fr it de he ja es pl cs nl sr sv pt_BR hu ru zh_CN"
IUSE="${IUSE}${IUSE_LINGUAS// / linguas_}"
REQUIRED_USE="assistant? ( gtk )"

PATCHES="${FILESDIR}/${P}-no-git.patch"

pkg_setup() {
	if ! use gtk && ! use ncurses ; then
		ewarn "gtk and ncurses are disabled."
		ewarn "At least one of these use flags are needed to get a front-end."
		ewarn "Only liblinphone is going to be installed."
	fi

	strip-linguas ${IUSE_LINGUAS}
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.6.1-nls.patch
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_DATE=NO
		-DENABLE_STRICT=NO
		-DENABLE_TUTORIALS=NO
		-DENABLE_CONSOLE_UI="$(usex ncurses)"
		-DENABLE_DOC="$(usex doc)"
		-DENABLE_TUNNEL="$(usex tunnel)"
		-DENABLE_GTK_UI="$(usex gtk)"
		-DENABLE_LDAP="$(usex ldap)"
		-DENABLE_LIME="$(usex lime)"
		-DENABLE_SQLITE_STORAGE="$(usex sqlite)"
		-DENABLE_TOOLS="$(usex tools)"
		-DENABLE_NOTFIY="$(usex libnotify)"
		-DENABLE_UNIT_TESTS="$(usex test)"
		-DENABLE_VIDEO="$(usex video)"
		-DENABLE_VCARD="$(usex vcard)"
		-DENABLE_ASSISTANT="$(usex assistant)"
		-DENABLE_CXX_WRAPPER="$(usex cxx)"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc AUTHORS BUGS ChangeLog NEWS README.md README.arm TODO
	pax-mark m "${ED%/}/usr/bin/linphone"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
