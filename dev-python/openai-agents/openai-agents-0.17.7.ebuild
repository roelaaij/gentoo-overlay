# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

# See https://github.com/openai/openai-python/blob/main/.stats.yml
MY_PN="openai-agents-python"
STDY_PV=0.19.7
DESCRIPTION="The official Python library for the openai API"
HOMEPAGE="
	https://github.com/openai/openai-agents-python
	https://pypi.org/project/openai-agents
"
SRC_URI="
	https://github.com/openai/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_PN}-${PV}.gh.tar.gz
"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/openai-2.36.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-15[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.2[${PYTHON_USEDEP}]
	>=dev-python/mcp-1.19.0[${PYTHON_USEDEP}]
	>=dev-python/griffelib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
"

src_unpack() {
	unpack "${MY_PN}-${PV}.gh.tar.gz"
}
