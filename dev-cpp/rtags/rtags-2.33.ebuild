# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils bash-completion-r1

RCT_COMMIT="7bd3732c232a1843990f67f41f1d86cb2c16f341"

DESCRIPTION="A c/c++ client/server indexer for c/c++/objc[++] with integration for Emacs based on clang. "
HOMEPAGE="https://github.com/Andersbakken/rtags"
SRC_URI="https://github.com/Andersbakken/rtags/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/Andersbakken/rct/archive/${RCT_COMMIT}.zip -> rct-${RCT_COMMIT}.zip"

RESTRICT="primaryuri"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RDEPENDS="sys-devel/llvm:7
		  sys-devel/clang:7"
DEPENDS="${RDEPENDS}"

IUSE="test"

src_unpack() {
	default
	mv "${WORKDIR}/rct-${RCT_COMMIT}"/* "${S}/src/rct" || die
}

src_configure() {
	local mycmakeargs=(
		-DEMACS=garbage
		-DBUILD_TESTING=$(usex test)
		-DBASH_COMPLETION_COMPLETIONSDIR=$(get_bashcompdir)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	rm ${D}/$(get_bashcompdir)/{rc,rdm} || die
	mv ${D}/$(get_bashcompdir)/rtags ${D}/$(get_bashcompdir)/rc || die
	bashcomp_alias rc rdm
}
