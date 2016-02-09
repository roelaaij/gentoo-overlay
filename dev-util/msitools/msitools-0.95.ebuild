# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit gnome.org

DESCRIPTION="A set of programs to inspect and build Windows Installer files."
HOMEPAGE="https://live.gnome.org/msitools"
#SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/msitools/${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/gcab
	gnome-extra/libgsf"
RDEPEND="${DEPEND}"

