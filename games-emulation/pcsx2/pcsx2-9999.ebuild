# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"

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
	dev-qt/qtbase:6[gui,network,widgets]
	dev-qt/qtsvg:6
	>=media-libs/libsdl2-2.0.22[haptic,joystick,sound]
"
DEPEND="${RDEPEND}
	>=dev-cpp/rapidyaml-0.3.0
	dev-cpp/sparsehash
"
BDEPEND="
	dev-lang/perl
	dev-qt/qttools[linguist]"

FILECAPS=(
	-m 0755 "CAP_NET_RAW+eip CAP_NET_ADMIN+eip" usr/bin/pcsx2
)

PATCHES=( "${FILESDIR}/libcommon-glad-static.patch"
		  "${FILESDIR}/visibility.patch"
		  "${FILESDIR}/jpgd-static.patch"
		  "${FILESDIR}/link-to-rt.patch"
		  "${FILESDIR}/qt6-no-linguist.patch"
		  "${FILESDIR}/static-core-library.patch"
		  "${FILESDIR}/more-system-libs.patch"
		  "${FILESDIR}/system-glslang.patch"
		  "${FILESDIR}/system-fast-float.patch"
		  "${FILESDIR}/auto-noderef.patch"
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

	sed -e "/EmuFolders::AppRoot =/s|=.*|= \"${EPREFIX}/usr/share/${PN}\";|" \
			-i pcsx2/Frontend/CommonHost.cpp || die
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
		-DBUILD_SHARED_LIBS=no
		-DDISABLE_BUILD_DATE=yes
		-DUSE_DISCORD_PRESENCE=FALSE
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
	# package mode was removed turning cmake_src_install into a noop
	newbin "${BUILD_DIR}"/bin/pcsx2-qt ${PN}

	insinto /usr/share/${PN}
	doins -r "${BUILD_DIR}"/bin/resources

	dodoc README.md bin/docs/{Debugger.pdf,GameIndex.pdf,PCSX2_FAQ.pdf,debugger.txt}
	newman bin/docs/PCSX2.1 ${PN}.1

	newicon linux_various/PCSX2.xpm ${PN}.xpm
	make_desktop_entry ${PN} ${PN^^}
}

pkg_postinst() {
	fcaps_pkg_postinst
}
