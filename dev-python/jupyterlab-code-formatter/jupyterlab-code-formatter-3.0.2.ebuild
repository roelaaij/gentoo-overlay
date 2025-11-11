# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Code formatting in Jupyter"
HOMEPAGE="https://jupyterlab-code-formatter.readthedocs.io"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
		$(python_gen_cond_dep '
				>=dev-python/importlib-metadata-4.13.0[${PYTHON_USEDEP}]
		' 3.11)
		dev-python/packaging[${PYTHON_USEDEP}]
"
BDEPEND="
		dev-python/hatch-nodejs-version[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
"

src_install() {
	distutils-r1_src_install
	mv "${D}/usr/etc" "${D}/etc"
}
