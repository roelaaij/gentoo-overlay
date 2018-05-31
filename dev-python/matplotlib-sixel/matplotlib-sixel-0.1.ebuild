# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6)

inherit distutils-r1

COMMIT=fc58a049fc695f4ccc24fbd1124a91bc99aa962b
DESCRIPTION="Routines for plotting area-weighted two- and three-circle venn diagrams"
HOMEPAGE="http://github.com/koppa/matplotlib-sixel"
SRC_URI="https://github.com/koppa/matplotlib-sixel/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND="
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	media-libs/libsixel"

S="${WORKDIR}/${PN}-${COMMIT}"

PATCHES="${FILESDIR}"/setup_py_unicode.patch
