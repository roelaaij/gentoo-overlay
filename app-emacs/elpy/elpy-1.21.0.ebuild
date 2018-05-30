# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
SITEFILE="50${PN}-gentoo.el"

inherit distutils-r1 elisp-common

DESCRIPTION="A helper library for integrating Python development in Emacs"
HOMEPAGE="http://github.com/jorgenschaefer/elpy"
SRC_URI="https://github.com/jorgenschaefer/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
IUSE=""
LICENSE="GPL"
SLOT="0"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
		virtual/emacs
		>=app-emacs/find-file-in-project-3.3
		>=app-emacs/pyvenv-1.3
		>=app-emacs/highlight-indentation-0.5.0
		>=app-emacs/company-mode-0.9.6
		>=app-emacs/yasnippet-0.8.0
		>=app-emacs/s-1.11.0"
RDEPEND="${DEPEND}
		|| ( dev-python/rope dev-python/jedi )
		dev-python/pyflakes
		dev-python/pip
		dev-python/nose
		>=dev-python/yapf-0.16.0"

src_compile() {
	distutils-r1_src_compile
	elisp-compile *.el || die
}

src_install() {
	distutils-r1_src_install
	elisp-install ${PN} *.el *.elc || die

}
