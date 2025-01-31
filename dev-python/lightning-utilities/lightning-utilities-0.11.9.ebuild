# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )
inherit distutils-r1

DESCRIPTION="Lightning AI utilities"
HOMEPAGE="
	https://github.com/Lightning-AI/utilities
	https://pypi.org/project/lightning-utilities/
"
SRC_URI="
	https://github.com/Lightning-AI/utilities/releases/download/v${PV}/${PN//-/_}-${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

S=${WORKDIR}/${PN//-/_}-${PV}
