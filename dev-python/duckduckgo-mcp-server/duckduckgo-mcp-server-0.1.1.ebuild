# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="MCP Server for searching via DuckDuckGo"
HOMEPAGE="https://github.com/nickclyde/duckduckgo-mcp-server"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/mcp[${PYTHON_USEDEP}]"

distutils_enable_tests pytest
