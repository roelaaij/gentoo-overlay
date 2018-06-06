# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="File dependency graph creator"
HOMEPAGE="http://pythondagger.sourceforge.net/"
SRC_URI="https://pypi.python.org/packages/d1/30/d0322306a06c5a5a071795e4dda9a0d82e9a281abd07f8fe137a59c3b353/dagger-1.3.0.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

PATCHES=" ${FILESDIR}/${PN}-python3.patch "
