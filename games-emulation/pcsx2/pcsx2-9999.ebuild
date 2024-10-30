# Copyright 1999-2024 Gentoo Authors
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
	media-libs/libsdl2[haptic,joystick]
	media-libs/libwebp:=
	media-video/ffmpeg:=
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
	vulkan? (
		media-libs/shaderc
		media-libs/vulkan-loader
		dev-libs/vulkan-memory-allocator
	)
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
	clang? ( sys-devel/clang:* )
	wayland? (
		dev-util/wayland-scanner
		kde-frameworks/extra-cmake-modules
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-unbundle.patch
	"${FILESDIR}"/${PN}-system-vulkan.patch
	"${FILESDIR}"/${PN}-1.7.3773-lto.patch
	"${FILESDIR}"/${PN}-1.7.4667-flags.patch
	"${FILESDIR}"/${PN}-fmt-10.patch
	"${FILESDIR}"/${PN}-1.7.5835-vanilla-shaderc.patch
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
			$(usev vulkan 'glslang vulkan-headers')
		)
		find 3rdparty -mindepth 1 -maxdepth 1 -type d \
			-not \( -false ${keep[*]/#/-o -name } \) -exec rm -r {} + || die

	fi

	# relax Qt6 and SDL2 version requirements which often get restricted
	# without a specific need, please report a bug to Gentoo (not upstream)
	# if a still-available older version is really causing issues
	sed -e '/find_package(\(Qt6\|SDL2\)/s/ [0-9.]*//' \
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
		-DENABLE_TESTS=$(usex test)
		-DUSE_LINKED_FFMPEG=yes
		-DUSE_VTUNE=no
		-DUSE_VULKAN=$(usex vulkan)
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
	insinto /usr/lib/${PN}
	doins -r "${BUILD_DIR}"/bin/.

	fperms +x /usr/lib/${PN}/pcsx2-qt
	dosym -r /usr/lib/${PN}/pcsx2-qt /usr/bin/${PN}

	newicon bin/resources/icons/AppIconLarge.png ${PN}.png
	make_desktop_entry ${PN} ${PN^^}

	dodoc README.md bin/docs/{Debugger.pdf,GameIndex.pdf,debugger.txt}

	use !test || rm "${ED}"/usr/lib/${PN}/*_test || die
}

pkg_postinst() {
	fcaps -m 0755 cap_net_admin,cap_net_raw=eip usr/lib/${PN}/pcsx2-qt

	if [[ ${REPLACING_VERSIONS##* } ]] &&
		ver_test ${REPLACING_VERSIONS##* } -lt 1.7; then
		elog ">=${PN}-1.7 has received several changes since <=${PN}-1.6.0, and is"
		elog "notably now a 64bit build using Qt6. Just-in-case it is recommended"
		elog "to backup configs, save states, and memory cards before using."
		elog
		elog "The executable was also renamed from 'PCSX2' to 'pcsx2'."
	fi
}
