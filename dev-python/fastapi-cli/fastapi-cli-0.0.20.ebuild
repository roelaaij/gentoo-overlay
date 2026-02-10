# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="Run and manage FastAPI apps from the command line with FastAPI CLI. 🚀"
HOMEPAGE="None"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND="dev-python/typer[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/rich-toolkit[${PYTHON_USEDEP}]
	dev-python/tomli[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/fastapi-cloud-cli[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/fastapi-new[${PYTHON_USEDEP}]"
distutils_enable_tests pytest
