# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_1{1..3} )
DISTUTILS_USE_PEP517=maturin

RUST_MIN_VER="1.85.0"
CRATES="
"

inherit cargo distutils-r1 pypi

SRC_URI+="
	${CARGO_CRATE_URIS}
	fastar-0.8.0-crates.tar.xz
"

DESCRIPTION="High-level bindings for the Rust tar crate"
HOMEPAGE="None"

LICENSE="MIT Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

distutils_enable_tests pytest
