# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit elisp

DESCRIPTION="Modern C++ font highlighting"
HOMEPAGE="https://github.com/ludwigpacifici/modern-cpp-font-lock"
SRC_URI="https://github.com/ludwigpacifici/${PN}-font-lock/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=app-emacs/faceup-0.1"
RDEPEND="${DEPEND}"

SITEFILE="50${PN}-gentoo.el"
DOCS="README.md CONTRIBUTING.md"

S="${WORKDIR}/${PN}-font-lock-${PV}"
