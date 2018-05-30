# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit elisp
DESCRIPTION="Yet another snippet extension for Emacs"
HOMEPAGE="https://github.com/capitaomorte/yasnippet"
SNIPPETS_VERSION="0.3"
SRC_URI="https://github.com/joaotavora/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/AndreaCrotti/${PN}-snippets/archive/${SNIPPETS_VERSION}.tar.gz -> ${PN}-snippets-${SNIPPET_VERSION}.tar.gz"

# Homepage says MIT licence, source contains GPL-2 copyright notice
LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=app-emacs/dropdown-list-20080316"
RDEPEND="${DEPEND}"

SITEFILE="50${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${PN}-snippets-${SNIPPETS_VERSION}" "${WORKDIR}/${P}/snippets"
	rm -r "${WORKDIR}/${P}/snippets/.{nosearch,gitignore}"
}

src_install() {
	elisp_src_install

	insinto "${SITEETC}/${PN}"
	doins -r snippets || die "doins failed"
}

pkg_postinst() {
	elisp-site-regen

	elog "Please add the following code into your .emacs to use yasnippet:"
	elog "(yas/initialize)"
	elog "(yas/load-directory \"${SITEETC}/${PN}/snippets\")"
}
