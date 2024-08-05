# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} pypy3 )
GENERATOR_V=2023.0.1
inherit distutils-r1

DESCRIPTION="Language Server Protocol types code generator & packages"
HOMEPAGE="
	https://github.com/microsoft/lsprotocol
	https://pypi.org/project/lsprotocol
"
SRC_URI="
	https://github.com/microsoft/lsprotocol/archive/refs/tags/${GENERATOR_V}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/cattrs[${PYTHON_USEDEP}]
"

S=${WORKDIR}/${PN}-${GENERATOR_V}/packages/python

src_prepare() {
	# poetry nonsense
	sed -i -e 's:\^:>=:' pyproject.toml || die
	distutils-r1_src_prepare
}
