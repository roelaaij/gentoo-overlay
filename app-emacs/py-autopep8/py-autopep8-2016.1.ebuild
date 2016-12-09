# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SITEFILE="50${PN}-gentoo.el"

inherit elisp

DESCRIPTION="A helper library for autopep8 support in Emacs"
HOMEPAGE="https://github.com/paetzke/${PN}.el"
SRC_URI="https://github.com/paetzke/${PN}.el/archive/v${PV}.tar.gz"

KEYWORDS="~amd64 ~x86"
IUSE=""
LICENSE="GPL"
SLOT="0"

DEPEND="virtual/emacs"
RDEPEND="${DEPEND}
		dev-python/autopep8"

S="${WORKDIR}/${PN}.el-${PV}"
