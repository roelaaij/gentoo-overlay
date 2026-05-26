# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_1{1..4} )

inherit distutils-r1 pypi

DESCRIPTION="The self-improving AI agent — creates skills from experience, improves them during use, and runs anywhere"
HOMEPAGE=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

distutils_enable_tests pytest
