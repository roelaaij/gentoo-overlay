# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit elisp
COMMIT="6c92dad56a133e14e7b27831e1bcf9b3a71ff154"
DESCRIPTION="emacs font lock testing"
HOMEPAGE="https://github.com/Lindydancer/faceup"
SRC_URI="${HOMEPAGE}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

SITEFILE="50${PN}-gentoo.el"
DOCS="README.md"

S="${WORKDIR}/${PN}-${COMMIT}"
