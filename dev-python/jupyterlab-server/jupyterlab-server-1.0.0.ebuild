# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1 toolchain-funcs

DESCRIPTION="JupyterLab"
HOMEPAGE="jupyter.org"

SRC_URI="mirror://pypi/${PN:0:1}/${PN//-/_}/${PN//-/_}-${PV}.tar.gz"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 ~mips ~ppc ppc64 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc test"

RDEPEND="net-libs/zeromq[drafts]
		 >=dev-python/notebook-5.0.0[${PYTHON_USEDEP}]
		 >=dev-python/bleach-2.1.1[${PYTHON_USEDEP}]
		 >=dev-python/jsonschema-2.6.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN//-/_}-${PV}"
