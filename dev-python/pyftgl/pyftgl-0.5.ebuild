# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit distutils-r1 eutils

DESCRIPTION="A Python wrapper for ftgl"
HOMEPAGE="https://code.google.com/archive/p/pyftgl"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pyftgl/PyFTGL-0.5c.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~x86"
IUSE=""

DEPEND="media-libs/ftgl
		media-libs/freetype
		dev-libs/boost[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"
src_prepare() {
	epatch "${FILESDIR}"/${P}-boost.patch
	default
}
