# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools ltprune

DESCRIPTION="A fast software implementation in C of the FIPS 180-2 hash algorithms SHA-224, SHA-256, SHA-384 and SHA-512"
HOMEPAGE="http://ouah.org/ogay/sha2/"
SRC_URI="http://ouah.org/ogay/sha2/sha2.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86"
IUSE=""

S=${WORKDIR}/sha2

src_prepare() {
	cp "${FILESDIR}/configure.ac" "${S}"
	cp "${FILESDIR}/Makefile.am" "${S}"
	rm "${S}/Makefile"
	eautoreconf
	default
}

src_configure() {
	econf --disable-static
}

src_install() {
	default
	prune_libtool_files
}
