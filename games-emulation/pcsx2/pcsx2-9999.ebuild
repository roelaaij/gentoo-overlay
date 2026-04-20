# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop fcaps flag-o-matic toolchain-funcs

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PCSX2/pcsx2.git"
else
	# unbundling on this package has become unmaintainable and, rather than
	# handle submodules separately, using a tarball that includes them
	SRC_URI="https://dev.gentoo.org/~ionen/distfiles/${P}.tar.xz"
	KEYWORDS="-* ~amd64"
fi

DESCRIPTION="PlayStation 2 emulator"
HOMEPAGE="https://pcsx2.net/"

LICENSE="
	GPL-3+ Apache-2.0 BSD BSD-2 BSD-4 Boost-1.0 CC0-1.0 GPL-2+
	ISC LGPL-2.1+ LGPL-3+ MIT OFL-1.1 ZLIB public-domain
"
SLOT="0"
IUSE="alsa cpu_flags_x86_sse4_1 +clang jack lto pulseaudio sndio test vulkan wayland"
REQUIRED_USE="cpu_flags_x86_sse4_1" # dies at runtime if no support
RESTRICT="!test? ( test )"

# dlopen: qtsvg, vulkan-loader, wayland
COMMON_DEPEND="
	app-arch/lz4:=
	app-arch/zstd:=
	dev-libs/libaio
	dev-libs/libfmt:=
	>=dev-libs/libbacktrace-20240503
	dev-qt/qtbase:6[concurrent,gui,widgets]
	dev-qt/qtsvg:6
	media-libs/freetype
	media-libs/libglvnd[X]
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	>=media-libs/libsdl3-3.2.6
	media-libs/libwebp:=
	media-video/ffmpeg:=
	>=media-libs/plutosvg-0.0.7
	net-libs/libpcap
	net-misc/curl
	sys-apps/dbus
	sys-libs/zlib:=
	virtual/libudev:=
	x11-libs/libXrandr
	alsa? ( media-libs/alsa-lib )
	jack? ( virtual/jack )
	pulseaudio? ( media-libs/libpulse )
	sndio? ( media-sound/sndio:= )
	media-libs/shaderc
	media-libs/vulkan-loader
	dev-libs/vulkan-memory-allocator
	wayland? ( dev-libs/wayland )
"
# patches is a optfeature but always pull given PCSX2 complaints if it
# is missing and it is fairly small (installs a ~1.5MB patches.zip)
RDEPEND="
	${COMMON_DEPEND}
	>=games-emulation/pcsx2_patches-0_p20230917
"
DEPEND="
	${COMMON_DEPEND}
	x11-base/xorg-proto
"
BDEPEND="
	dev-qt/qttools:6[linguist]
	clang? ( llvm-core/clang:* )
	wayland? (
		dev-util/wayland-scanner
		kde-frameworks/extra-cmake-modules
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-unbundle.patch
	"${FILESDIR}"/${PN}-system-vulkan.patch
	"${FILESDIR}"/${PN}-1.7.3773-lto.patch
	"${FILESDIR}"/${PN}-fmt-11.patch
	"${FILESDIR}"/${PN}-fix-build.patch
)

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		local EGIT_SUBMODULES=(
			# has no build system and is not really setup for unbundling
			3rdparty/rcheevos/rcheevos

			# not in tree
			3rdparty/lzma
			3rdparty/libchdr

			# system rapidyaml is still used, but this uses another part
			# of the source directly (fast_float) and so allow the submodule
			# https://github.com/PCSX2/pcsx2/commit/af646e449
			3rdparty/rapidyaml/rapidyaml
			3rdparty/rapidyaml/rapidyaml/extern/c4core
			3rdparty/rapidyaml/rapidyaml/ext/c4core/src/c4/ext/fast_float
		)

		git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	cmake_src_prepare

	sed -e "/EmuFolders::AppRoot =/s|=.*|= \"${EPREFIX}/usr/share/${PN}\";|" \
		-i pcsx2/Pcsx2Config.cpp || die

	if [[ ${PV} != 9999 ]]; then
		sed -e '/set(PCSX2_GIT_TAG "")/s/""/"v'${PV}'"/' \
			-i cmake/Pcsx2Utils.cmake || die

		# delete all 3rdparty/* except known-used ones in non-live
		local keep=(
			# TODO?: rapidjson and xbyak are packaged and could be unbundlable
			# w/ patch, and discord-rpc be optional w/ dependency on rapidjson
			demangler discord-rpc glad imgui include jpgd
			rapidyaml rcheevos xbyak zydis
			glslang vulkan-headers
		)
		find 3rdparty -mindepth 1 -maxdepth 1 -type d \
			-not \( -false ${keep[*]/#/-o -name } \) -exec rm -r {} + || die

	fi

	# relax Qt6 and SDL2 version requirements which often get restricted
	# without a specific need, please report a bug to Gentoo (not upstream)
	# if a still-available older version is really causing issues
	sed -e '/find_package(\(Qt6\|SDL3\)/s/ [0-9.]*/ /' \
		-i cmake/SearchForStuff.cmake || die

	# pluto(s)vg likewise often restrict versions and Gentoo also does not
	# have .cmake files for it, use sed to avoid rebasing on version changes
	sed -e '/^find_package(plutovg/d' \
		-e '/^find_package(plutosvg/c\
			find_package(PkgConfig REQUIRED)\
			pkg_check_modules(plutovg REQUIRED IMPORTED_TARGET plutovg)\
			alias_library(plutovg::plutovg PkgConfig::plutovg)\
			pkg_check_modules(plutosvg REQUIRED IMPORTED_TARGET plutosvg)\
			alias_library(plutosvg::plutosvg PkgConfig::plutosvg)' \
		-i cmake/SearchForStuff.cmake || die
}

src_configure() {
	# note that upstream only supports clang and ignores gcc issues, e.g.
	# https://github.com/PCSX2/pcsx2/issues/10624#issuecomment-1890326047
	# (CMakeLists.txt also gives a big warning if compiler is not clang)
	if use clang && ! tc-is-clang; then
		local -x CC=${CHOST}-clang CXX=${CHOST}-clang++
		strip-unsupported-flags
	fi

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=no
		-DDISABLE_ADVANCE_SIMD=no
		-DPACKAGE_MODE=yes
		-DUSE_BACKTRACE=no # not packaged (bug #885471)
		-DENABLE_TESTS=$(usex test)
		-DUSE_LINKED_FFMPEG=yes
		-DUSE_VTUNE=no
		-DUSE_VULKAN=yes
		-DWAYLAND_API=$(usex wayland)
		-DX11_API=yes # X libs are currently hard-required either way
		-DLTO_PCSX2_CORE=$(usex lto)
	)

	cmake_src_configure
}

src_test() {
	cmake_build unittests
}

src_install() {
	cmake_src_install

	newicon bin/resources/icons/AppIconLarge.png pcsx2.png
	make_desktop_entry pcsx2-qt PCSX2

	dodoc README.md bin/docs/GameIndex.pdf
}

pkg_postinst() {
	fcaps cap_net_admin,cap_net_raw=eip usr/bin/pcsx2-qt

	# calls aplay or gst-play/launch-1.0 as fallback
	# https://github.com/PCSX2/pcsx2/issues/11141
	optfeature "UI sound effects support" \
		media-sound/alsa-utils \
		media-libs/gst-plugins-base:1.0

	if ver_replacing -lt 2.2.0; then
		elog
		elog "Note that the 'pcsx2' executable was renamed to 'pcsx2-qt' with this version."
	fi
}
