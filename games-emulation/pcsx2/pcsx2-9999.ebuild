# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.1-gtk3"

inherit cmake flag-o-matic git-r3 toolchain-funcs wxwidgets fcaps

DESCRIPTION="A PlayStation 2 emulator"
HOMEPAGE="https://www.pcsx2.net"
EGIT_REPO_URI="https://github.com/PCSX2/${PN}.git"
EGIT_SUBMODULES=( '3rdparty/imgui/imgui' )

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="cubeb opengl vulkan wayland X qt wxWidgets"

REQUIRED_USE="X? ( wxWidgets )
			  wayland? ( wxWidgets )
			  ^^ ( wxWidgets qt )"

RDEPEND="
	app-arch/bzip2
	app-arch/xz-utils
	dev-libs/libaio
	dev-libs/libxml2:2
	media-libs/alsa-lib
	media-libs/libpng:=
	media-libs/libsoundtouch
	net-libs/libpcap
	sys-libs/zlib
	dev-libs/libzip[zstd]
	dev-libs/cpuinfo
	virtual/libudev
	dev-libs/libchdr
	media-libs/cubeb
	cubeb? ( media-libs/cubeb )
	opengl? ( virtual/opengl )
	vulkan? ( media-libs/vulkan-loader:= )
	wayland? (
		  >=dev-libs/wayland-1.20.0
		  >=dev-libs/wayland-protocols-1.23
		  media-libs/mesa[wayland]
		  >=x11-libs/libxkbcommon-0.2
	)
	X? (
		   x11-libs/libICE
		   x11-libs/libX11
		   x11-libs/libXext
		   x11-libs/libxcb
	)
	wxWidgets? (
		   x11-libs/wxGTK:3.1-gtk3[X]
		   >=media-libs/libsdl2-2.0.12[haptic,joystick,sound]
	)
	qt? (
		   dev-qt/qtbase[gui,widgets,network]
		   >=media-libs/libsdl2-2.0.22[haptic,joystick,sound]
	)
"
DEPEND="${RDEPEND}
	dev-cpp/pngpp
	>=dev-cpp/rapidyaml-0.3.0
	dev-cpp/sparsehash
"

PATCHES=( "${FILESDIR}/libcommon-glad-static.patch"
		  "${FILESDIR}/visibility.patch"
		  "${FILESDIR}/jpgd-static.patch"
		  "${FILESDIR}/system-glslang.patch"
		  "${FILESDIR}/link-to-rt.patch"
		  "${FILESDIR}/qt6-no-linguist.patch"
		  "${FILESDIR}/static-core-library.patch"
		  "${FILESDIR}/more-system-libs.patch"
		  "${FILESDIR}/fix-resource-dir.patch"
		  "${FILESDIR}/system-fast-float.patch"
		  "${FILESDIR}/${PN}-fix-no-achievements.patch"
		)

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary && $(tc-getCC) == *gcc* ]]; then
		# -mxsave flag is needed when GCC >= 8.2 is used
		# https://bugs.gentoo.org/685156
		if [[ $(gcc-major-version) -gt 8 || $(gcc-major-version) == 8 && $(gcc-minor-version) -ge 2 ]]; then
			append-flags -mxsave
		fi
	fi
}

src_prepare() {
	rm -rf 3rdparty/fmt || die
	cmake_src_prepare
}

src_configure() {
	# multilib_toolchain_setup x86
	# Build with ld.gold fails
	# https://github.com/PCSX2/pcsx2/issues/1671
	tc-ld-disable-gold

	# pcsx2 build scripts will force CMAKE_BUILD_TYPE=Devel
	# if it something other than "Devel|Debug|Release"
	local CMAKE_BUILD_TYPE="Release"

	local mycmakeargs=(
		-DDISABLE_BUILD_DATE=TRUE
		-DDISABLE_PCSX2_WRAPPER=TRUE
		-DPACKAGE_MODE=ON
		-DXDG_STD=TRUE
		-DDISABLE_SETCAP=TRUE
		-DCMAKE_LIBRARY_PATH="/usr/$(get_libdir)/${PN}"
		-DCUBEB_API=$(usex cubeb)
		-DX11_API=$(usex X)
		-DWAYLAND_API=$(usex wayland)
		-DQT_BUILD=$(usex qt)
		-DUSE_VULKAN=$(usex vulkan)
		-DUSE_OPENGL=$(usex opengl)
		-DUSE_VTUNE=FALSE
		-DENABLE_TESTS=FALSE
		-DUSE_ACHIEVEMENTS=FALSE
	)

	if use wxWidgets; then
		setup-wxwidgets
	fi
	cmake_src_configure
}

src_install() {
	# Upstream issues:
	#  https://github.com/PCSX2/pcsx2/issues/417
	#  https://github.com/PCSX2/pcsx2/issues/3077
	QA_EXECSTACK="usr/bin/pcsx2"
	QA_TEXTRELS="usr/$(get_libdir)/pcsx2/* usr/bin/pcsx2"
	cmake_src_install
}

pkg_postinst() {
	fcaps "CAP_NET_RAW+eip CAP_NET_ADMIN+eip" $(usex qt 'usr/bin/pcsx2-qt' 'usr/bin/pcsx2')
}
