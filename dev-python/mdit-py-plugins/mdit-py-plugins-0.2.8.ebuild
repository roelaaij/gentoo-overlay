# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )
inherit distutils-r1

DESCRIPTION="A Python port of markdown-it, and some of its associated plugins"
HOMEPAGE="https://github.com/executablebooks/${PN}"
SRC_URI="https://github.com/executablebooks/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="
	dev-python/markdown-it-py[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
