# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="Rich toolkit for building command-line applications"
HOMEPAGE="None"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND="dev-python/click[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]"
distutils_enable_tests pytest
