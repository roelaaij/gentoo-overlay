# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="Create a new FastAPI project in one command"
HOMEPAGE="None"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND="
	dev-util/prek
	dev-util/ruff
	dev-python/typer[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/rich-toolkit[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/coverage[${PYTHON_USEDEP}]
	dev-python/mypy[${PYTHON_USEDEP}]
	"
distutils_enable_tests pytest
