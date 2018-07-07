# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 eutils

DESCRIPTION="Pure-python implementation of ROOT I/O"
HOMEPAGE="https://github.com/scikit-hep/uproot"
SRC_URI="https://github.com/scikit-hep/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="xrootd lz4 lzma"

RDEPEND="dev-python/numpy[${PYTHON_USEDEP}]
		 xrootd? ( net-libs/xrootd[python,python_targets_python2_7(-)?] )
		 lz4? ( app-arch/lz4 )
		 lzma? ( app-arch/xz-utils )"
DEPEND="${RDEPEND}"

python_test() {
  esetup.py test
}
