# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/lsalzman/enet.git"
inherit autotools git-r3

DESCRIPTION="Relatively thin, simple and robust network communication layer on top of UDP"
HOMEPAGE="http://enet.bespin.org/ https://github.com/lsalzman/enet/"

LICENSE="MIT"
SLOT="1.3/8"
KEYWORDS="amd64 ~arm64 ~loong ppc ~ppc64 ~riscv x86"
IUSE="static-libs"

RDEPEND="!${CATEGORY}/${PN}:0"

src_configure() {
	eautoreconf
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
