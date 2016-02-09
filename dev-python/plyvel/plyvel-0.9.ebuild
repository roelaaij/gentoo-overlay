# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_2 python3_3 python3_4 pypy )

inherit distutils-r1

DESCRIPTION="Python interface to LevelDB"
HOMEPAGE=""
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
KEYWORDS="amd64 x86"
SLOT="0"
IUSE=""

RDEPEND=">=dev-libs/leveldb-1.18"
