# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils

DESCRIPTION="Open Real-time Transport Protocol (RTP, RFC3550) stack"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/9"
KEYWORDS="alpha amd64 ia64 ppc ppc64 sparc x86 ~x86-fbsd ~ppc-macos ~x64-macos ~x86-macos"
IUSE="debug doc examples libressl minimal ntp-timestamp ssl test"

RDEPEND="
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= ) )
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	virtual/pkgconfig
	>=net-libs/bctoolbox-0.5.1
"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_STRICT=NO
		-DENABLE_NTP_TIMESTAMP="$(usex ntp-timestamp)"
		-DENABLE_PERF="$(usex minimal)"
		-DENABLE_DOC="$(usex doc)"
		-DENABLE_DEBUG_LOGS="$(usex debug)"
		-DENABLE_TESTS="$(usex test)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	prune_libtool_files

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins src/tests/*.c
	fi
}
