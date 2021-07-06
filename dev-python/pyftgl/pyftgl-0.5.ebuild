# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{3_8,3_9} )

inherit distutils-r1 eutils

DESCRIPTION="A Python wrapper for ftgl"
HOMEPAGE="https://code.google.com/archive/p/pyftgl"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pyftgl/PyFTGL-0.5c.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~x86"
IUSE=""

DEPEND="media-libs/ftgl
		media-libs/freetype
		dev-libs/boost[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

PATCHES=( "${FILESDIR}"/${P}-boost.patch )
