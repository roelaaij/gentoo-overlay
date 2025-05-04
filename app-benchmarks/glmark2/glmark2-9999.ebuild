# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{11,12,13} )
inherit waf-utils python-single-r1 git-r3

DESCRIPTION="Opengl test suite"
HOMEPAGE="https://launchpad.net/glmark2"
SRC_URI=""
EGIT_REPO_URI="https://github.com/glmark2/glmark2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="drm gles2 +opengl wayland X"

RDEPEND="media-libs/libpng
	media-libs/mesa[gles2?]
	X? ( x11-libs/libX11 )
	wayland? ( >=dev-libs/wayland-1.2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="|| ( opengl gles2 )
			  || ( drm wayland X )"

src_prepare() {
	default
	rm -rf "${S}/src/libpng"
	sed -i "s/libpng15/libpng/g" "${S}/wscript" # allow build with >= libpng:1.6
}

src_configure() {
	: ${WAF_BINARY:="${S}/waf"}

	local myconf

	if use X; then
		use opengl && myconf+="x11-gl"
		use gles2 && myconf+=",x11-glesv2"
	fi

	if use drm; then
		use opengl && myconf+=",drm-gl"
		use gles2 && myconf+=",drm-glesv2"
	fi

	if use wayland; then
		use opengl && myconf+=",wayland-gl"
		use gles2 && myconf+=",wayland-glesv2"

	fi
	myconf=${myconf#,}

	# it does not know --libdir specification, dandy huh
	CCFLAGS="${CFLAGS}" LINKFLAGS="${LDFLAGS}" "${WAF_BINARY}" \
		--prefix=/usr \
		--with-flavors ${myconf} \
		configure || die "configure failed"
}
