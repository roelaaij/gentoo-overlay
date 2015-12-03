# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/plasma-widget-message-indicator/plasma-widget-message-indicator-0.5.8.ebuild,v 1.3 2014/03/21 18:57:18 johu Exp $

EAPI=5

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="Plasmoid for managing CPU frequency"
HOMEPAGE="https://launchpad.net/plasma-widget-message-indicator"
SRC_URI="http://kde-apps.org/CONTENT/content-files/144809-kde-plasma-cpufrequtility-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="
	>=kde-base/pykde4-4.12.5
"

DEPEND="
	${RDEPEND}
"

S="${WORKDIR}/kde-plasma-cpufrequtility-1.6"
