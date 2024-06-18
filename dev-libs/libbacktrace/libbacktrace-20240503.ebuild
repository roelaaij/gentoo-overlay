# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Library to produce symbolic backtraces"
HOMEPAGE="https://github.com/ianlancetaylor/libbacktrace"
LIBBACKTRACE_COMMIT="11427f31a64b11583fec94b4c2a265c7dafb1ab3"
SRC_URI="https://github.com/ianlancetaylor/${PN}/archive/${LIBBACKTRACE_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${LIBBACKTRACE_COMMIT}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Tests fail with llvm-objcopy
RESTRICT="test"

src_configure() {
	# Breaks due to grepping an object file
	filter-lto

	econf \
		--disable-werror \
		--enable-shared
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
