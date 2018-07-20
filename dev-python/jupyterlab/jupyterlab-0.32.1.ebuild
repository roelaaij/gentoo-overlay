# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_REQ_USE="threads(+)"

inherit flag-o-matic distutils-r1 toolchain-funcs

DESCRIPTION="JupyterLab"
HOMEPAGE="jupyter.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 ~mips ~ppc ppc64 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc test"

RDEPEND=">=dev-python/notebook-5.0.0
		 <dev-python/jupyterlab-launcher-0.11.0
		 dev-python/ipython_genutils
		 >=net-libs/nodejs-8.1.0[npm]
"
DEPEND="${RDEPEND}"
