# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="An extremely small, fast enough vector search SQLite extension that runs anywhere!"
HOMEPAGE="https://github.com/asg017/${PN}"
SRC_URI="https://github.com/asg017/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-db/sqlite:=
"
DEPEND="${RDEPEND}
"

src_compile() {
	emake loadable \
		CFLAGS="${CFLAGS}" || die
}

src_install() {
	dolib.so dist/vec0.so
}
