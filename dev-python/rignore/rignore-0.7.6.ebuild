# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_1{1..3} )

inherit cargo distutils-r1 pypi

SRC_URI+="
	rignore-0.7.6-crates.tar.xz
"

DESCRIPTION="Python Bindings for the ignore crate"
HOMEPAGE="None"

LICENSE="MIT Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

distutils_enable_tests pytest
