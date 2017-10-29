# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGIT_REPO_URI="https://github.com/TASVideos/desmume"

inherit autotools git-r3

DESCRIPTION="Nintendo DS emulator"
HOMEPAGE="http://desmume.org/"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8.0:2
	gnome-base/libglade
	x11-libs/gtkglext
	virtual/opengl
	sys-libs/zlib
	dev-libs/zziplib
	media-libs/libsdl[joystick,opengl,video]
	x11-libs/agg"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

PATCHES=(
	   "${FILESDIR}/${PN}-cspace-includes.patch"
)

src_prepare() {
	default
	S="${WORKDIR}/${P}/${PN}/src/frontend/posix"
	cd "${S}"
	eautoreconf
}

src_install() {
	DOCS="../../../AUTHORS ../../../ChangeLog ../../../README ../../../README.LIN" \
		default
}
