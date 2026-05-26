# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_1{1..4} )

inherit distutils-r1 pypi

DESCRIPTION="Radically simplified static file serving for WSGI applications"
HOMEPAGE=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="brotli"
RDEPEND="brotli? ( dev-python/brotlicffi )"

distutils_enable_tests pytest
