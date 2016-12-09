# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SITEFILE="50${PN}-gentoo.el"

inherit elisp

DESCRIPTION="A helper library for integrating Python development in Emacs"
HOMEPAGE="https://github.com/abo-abo/swiper"
SRC_URI="https://github.com/abo-abo/${PN}/archive/${PV}.tar.gz"
KEYWORDS="~amd64 ~x86"
IUSE=""
LICENSE="GPL"
SLOT="0"

DEPEND="virtual/emacs"
RDEPEND="${DEPEND}"

src_compile() {
	elisp-compile ivy.el swiper.el counsel.el || die
}

src_install() {
	elisp-install ${PN} ivy.el swiper.el counsel.el *.elc || die

}
