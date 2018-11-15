# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=6

inherit autotools

DESCRIPTION="Reflow text extracted from pdf into HTML"
HOMEPAGE="https://sourceforge.net/project/pdfreflow"
SRC_URI="https://downloads.sourceforge.net/project/pdfreflow/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

src_prepare() {
	default
	eautoreconf
}
