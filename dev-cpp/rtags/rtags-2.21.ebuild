# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit elisp cmake-utils

RCT_COMMIT="d77562b511ad7e5c4877abb41154c80668c86e4b"

DESCRIPTION="A c/c++ client/server indexer for c/c++/objc[++] with integration for Emacs based on clang. "
HOMEPAGE="https://github.com/Andersbakken/rtags"
SRC_URI="https://github.com/Andersbakken/rtags/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/Andersbakken/rct/archive/${RCT_COMMIT}.zip -> rct-latest.zip"

RESTRICT="primaryuri"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPENDS="!app-emacs/rtags
		  sys-devel/llvm:7
		  sys-devel/clang:7"
DEPENDS="${RDEPENDS}"

SITEFILE="50${PN}-gentoo.el"

pkg_setup() {
	elisp_pkg_setup
}

src_unpack() {
	elisp_src_unpack
	mv "${WORKDIR}/rct-${RCT_COMMIT}"/* "${S}/src/rct" || die
}

src_prepare() {
	elisp_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	cd "${S}/src" || die
	elisp_src_compile
	cd "${S}" || die
}

src_install() {
	cmake-utils_src_install
	cd "${S}/src" || die
	elisp_src_install
	cd "${S}" || die
}

pkg_postinst() {
	elisp_pkg_postinst
}

pkg_postrm() {
	elisp_pkg_postrm
}
