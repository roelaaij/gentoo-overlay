# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

DESCRIPTION="Language Server Protocol types code generator & packages"
HOMEPAGE="
	https://github.com/microsoft/lsprotocol
	https://pypi.org/project/lsprotocol
"
SRC_URI="
	https://github.com/microsoft/lsprotocol/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/cattrs[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
			dev-python/importlib-resources[${PYTHON_USEDEP}]
	' 3.{10..11})
"
BDEPEND="
	test? (
		>=dev-python/pytest-7.4.3[${PYTHON_USEDEP}]
		dev-python/pyhamcrest[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	# poetry nonsense
	sed -i -e 's:\^:>=:' pyproject.toml || die
	distutils-r1_src_prepare
}
