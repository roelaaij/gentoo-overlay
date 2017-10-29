# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic kde5

DESCRIPTION="KWallet CLI"
HOMEPAGE="https://www.mirbsd.org/kwalletcli.htm"
SRC_URI="https://www.mirbsd.org/MirOS/dist/hosted/kwalletcli/kwalletcli-3.00.tar.gz -> ${P}.tar.gz"

LICENSE="MirOS"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="
	$(add_frameworks_dep kwallet)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kcoreaddons)
"
RDEPEND="
	${DEPEND}
	app-shells/mksh"

S="${WORKDIR}/${PN}"

src_prepare() {
	default
}

src_configure() {
	append-cppflags -fPIC -DPIC
	default
}

src_compile() {
	emake KDE_VER=5
}

src_install() {
	mkdir -p "${D}${EPREFIX}"usr/bin
	mkdir -p "${D}${EPREFIX}"usr/share/man/man1
	emake DESTDIR="${D}" \
		  BINDIR="${EPREFIX}"usr/bin \
		  MANDIR="${EPREFIX}"usr/share/man/man \
		  install
	for size in 32 64 128; do
		doicon -s ${size} "${PN}${size}.png"
	done
	doicon "${PN}.svg"
}
