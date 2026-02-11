# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="SSE plugin for Starlette"
HOMEPAGE="None"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE="uvicorn daphne"
RDEPEND="
	dev-python/starlette[${PYTHON_USEDEP}]
	dev-python/anyio[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/fastapi[${PYTHON_USEDEP}]
	dev-python/sqlalchemy[${PYTHON_USEDEP}]
	dev-python/aiosqlite[${PYTHON_USEDEP}]
	uvicorn? ( dev-python/uvicorn[${PYTHON_USEDEP}] )
	daphne? ( dev-python/daphne[${PYTHON_USEDEP}] )"
distutils_enable_tests pytest
