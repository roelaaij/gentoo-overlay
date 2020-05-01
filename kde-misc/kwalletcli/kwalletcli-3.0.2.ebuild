# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

KFMIN=5.67.0
QTMIN=5.12.3

inherit flag-o-matic kde.org desktop

DESCRIPTION="KWallet CLI"
HOMEPAGE="https://www.mirbsd.org/kwalletcli.htm"
SRC_URI="https://www.mirbsd.org/MirOS/dist/hosted/kwalletcli/${PN}-3.02.tar.gz -> ${P}.tar.gz"

LICENSE="MirOS"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="
	>=kde-frameworks/kwallet-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
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
	mkdir -p "${D}${EPREFIX}"/usr/bin
	mkdir -p "${D}${EPREFIX}"/usr/share/man/man1
	emake DESTDIR="${D}" \
		  BINDIR="${EPREFIX}"/usr/bin \
		  MANDIR="${EPREFIX}"/usr/share/man/man \
		  install
	for size in 32 64 128; do
		doicon -s ${size} "${PN}${size}.png"
	done
	doicon "${PN}.svg"
}
