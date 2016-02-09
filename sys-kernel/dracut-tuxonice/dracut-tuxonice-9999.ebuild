# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit git-2

DESCRIPTION="TuxOnIce module for dracut"
HOMEPAGE="https://github.com/milo000/dracut-tuxonice"
EGIT_REPO_URI="git://github.com/milo000/dracut-tuxonice.git"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-kernel/dracut"
RDEPEND="${DEPEND}"

src_install() {
dodir /usr/lib/dracut/modules.d/
cp -R "${S}/95tuxonice/" "${D}/usr/lib/dracut/modules.d/" || die "Install failed"
}