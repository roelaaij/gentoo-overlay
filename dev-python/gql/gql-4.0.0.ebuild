# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="A GraphQL client in Python "
HOMEPAGE="https://github.com/graphql-python/gql"

SRC_URI="$(pypi_sdist_url) -> ${P}.tar.gz"
KEYWORDS="amd64"

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-python/graphql-core[${PYTHON_USEDEP}]
	dev-python/yarl[${PYTHON_USEDEP}]
	dev-python/tenacity[${PYTHON_USEDEP}]
	dev-python/anyio[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]

"
BDEPEND="
	test? (
		>=dev-python/parse-1.20.2[${PYTHON_USEDEP}]
		>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-9.1.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-asyncio-1.4.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-console-scripts-1.4.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-cov-7.1.0[${PYTHON_USEDEP}]
		>=dev-python/vcrpy-8.2.1[${PYTHON_USEDEP}]
		dev-python/aiofiles[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
