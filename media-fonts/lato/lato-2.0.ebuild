# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit font versionator

MY_P="Lato2OFL"

DESCRIPTION="Fonts from the Lato Project"
HOMEPAGE="http://latofonts.com/"
SRC_URI="http://www.latofonts.com/download/Lato2OFL.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sparc x86"
IUSE=""

RDEPEND="!<x11-libs/pango-1.20.4"

S="${WORKDIR}/${MY_P}"
FONT_S="${S}"
FONT_SUFFIX="ttf"
DOCS="README.txt"
