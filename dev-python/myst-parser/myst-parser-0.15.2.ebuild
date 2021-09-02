# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )
inherit distutils-r1


MY_PN="MyST-Parser"

DESCRIPTION="An extended commonmark compliant parser, with bridges to docutils & sphinx."
HOMEPAGE="https://github.com/executablebooks/${MY_PN}"
SRC_URI="https://github.com/executablebooks/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="
	dev-python/markdown-it-py[${PYTHON_USEDEP}]
	dev-python/mdit-py-plugins[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
	>=dev-python/sphinx-3.5.4[${PYTHON_USEDEP}]
	>=dev-python/jinja-3.0.0[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${MY_PN}-${PV}"
