# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{10..12} pypy3 )

inherit distutils-r1

DESCRIPTION="CMake LSP server"
HOMEPAGE="
	https://github.com/regen100/cmake-language-server
	https://pypi.org/project/cmake-language-server
"
SRC_URI="
	https://github.com/regen100/cmake-language-server/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	>=dev-python/pygls-1.1.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/pytest-7.2.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-datadir-1.4.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-cov-4.0.0[${PYTHON_USEDEP}]
		>=dev-util/cmakelang-0.6.13[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	# poetry nonsense
	sed -i -e 's:\^:>=:' pyproject.toml || die
	distutils-r1_src_prepare
}

src_compile() {
	export PDM_BUILD_SCM_VERSION=${PV}
	distutils-r1_src_compile
}
