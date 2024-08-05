# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

DESCRIPTION="A python generic language server"
HOMEPAGE="
	https://github.com/openlawlibrary/pygls
	https://pypi.org/project/pygls
"
SRC_URI="
	https://github.com/openlawlibrary/pygls/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"
IUSE="websockets"

RDEPEND="
	>=dev-python/cattrs-23.1.2[${PYTHON_USEDEP}]
	>=dev-python/lsprotocol-2023.0.1[${PYTHON_USEDEP}]
	websockets? (
		>=dev-python/websockets-11.0.3[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	test? (
		>=dev-python/coverage-7.3.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-7.4.3[${PYTHON_USEDEP}]
		>=dev-python/pytest-asyncio-0.21.0[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	# poetry nonsense
	sed -i -e 's:\^:>=:' pyproject.toml || die
	distutils-r1_src_prepare
}
