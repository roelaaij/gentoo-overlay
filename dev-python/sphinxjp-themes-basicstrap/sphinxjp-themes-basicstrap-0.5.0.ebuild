# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{8,9} )
inherit distutils-r1

PYPI_PN="${PN//-/.}"
DESCRIPTION="sphinx extension to support coroutines in markup"
HOMEPAGE="https://github.com/tell-k/sphinxjp.themes.basicstrap"
SRC_URI="mirror://pypi/${PYPI_PN:0:1}/${PYPI_PN}/${PYPI_PN}-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
"
RDEPEND="dev-python/sphinx[${PYTHON_USEDEP}]"

S="${WORKDIR}/${PYPI_PN}-${PV}"

src_prepare() {
	sed -i -E 's/setup_requires=/# setup_requires=/g' setup.py
	distutils-r1_src_prepare
}

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
