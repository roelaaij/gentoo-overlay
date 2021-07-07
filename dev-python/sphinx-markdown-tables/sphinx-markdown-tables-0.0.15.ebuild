# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )
inherit distutils-r1

DESCRIPTION="sphinx extension to support markdown tables"
HOMEPAGE="https://github.com/ryanfox/sphinx-markdown-tables"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
"
RDEPEND="dev-python/sphinx[${PYTHON_USEDEP}]"

python_compile_all() {
	use doc && emake -C docs html
}

python_install() {
	distutils-r1_python_install --skip-build
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
	# clean up pth files bug #623852
	find "${ED}" -name '*.pth' -delete || die
}
