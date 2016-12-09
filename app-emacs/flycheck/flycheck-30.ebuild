# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SITEFILE="50${PN}-gentoo.el"

inherit elisp

DESCRIPTION="A helper library for on the fly syntax checking in Emacs"
HOMEPAGE="https://github.com/flycheck/flycheck"
SRC_URI="https://github.com/flycheck/${PN}/archive/${PV}.tar.gz"

KEYWORDS="~amd64 ~x86"
IUSE="cpp asciidoc ada python"
LICENSE="GPL"
SLOT="0"

DEPEND="virtual/emacs"
RDEPEND="${DEPEND}
		cpp? ( dev-util/cppcheck )
		asciidoc? ( app-text/asciidoc )
		ada? ( virtual/gnat )
		python? ( || ( dev-python/flake8 dev-python/pylint ) )"
