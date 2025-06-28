# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1

DESCRIPTION="A gssapi authentication handler for python-requests"
HOMEPAGE="
	https://github.com/pythongssapi/requests-gssapi
"
SRC_URI="
	https://github.com/pythongssapi/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="ISC"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv x86"

RDEPEND="
	>=dev-python/requests-1.1.0[${PYTHON_USEDEP}]
	dev-python/gssapi[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/tox[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
