# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils flag-o-matic cmake-utils

DESCRIPTION="C object oriented SIP Stack."
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

SLOT="0"

IUSE="test examples tunnel"
REQUIRED_USE=""

DEPEND="${RDEPEND}
	>=dev-libs/antlr-c-3.5.2
	dev-java/antlr:3
	virtual/pkgconfig
	test? ( >=dev-util/cunit-2.1_p2[ncurses] )"

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_STRICT=NO
		-DENABLE_TESTS="$(usex test)"
		-DENABLE_TUNNEL="$(usex tunnel)"
	)
	cmake-utils_src_configure
}

src_test() {
	default
	cd tester || die
	emake -C tester test
}

src_install() {
	cmake-utils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tester/*.c
	fi
}
