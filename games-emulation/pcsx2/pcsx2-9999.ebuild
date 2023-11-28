# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop fcaps flag-o-matic

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PCSX2/pcsx2.git"
else
	HASH_FASTFLOAT=32d21dcecb404514f94fb58660b8029a4673c2c1
	HASH_RCHEEVOS=31f8788fe0e694e99db7ce138d45a655c556fa96
	HASH_GLSLANG=c9706bdda0ac22b9856f1aa8261e5b9e15cd20c5
	HASH_VULKAN=9f4c61a31435a7a90a314fc68aeb386c92a09c0f
	SRC_URI="
		https://github.com/PCSX2/pcsx2/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/fastfloat/fast_float/archive/${HASH_FASTFLOAT}.tar.gz
			-> ${PN}-fast_float-${HASH_FASTFLOAT::10}.tar.gz
		https://github.com/RetroAchievements/rcheevos/archive/${HASH_RCHEEVOS}.tar.gz
			-> ${PN}-rcheevos-${HASH_RCHEEVOS::10}.tar.gz
		vulkan? (
			https://github.com/KhronosGroup/glslang/archive/${HASH_GLSLANG}.tar.gz
				-> ${PN}-glslang-${HASH_GLSLANG::10}.tar.gz
			https://github.com/KhronosGroup/Vulkan-Headers/archive/${HASH_VULKAN}.tar.gz
				-> ${PN}-vulkan-headers-${HASH_VULKAN::10}.tar.gz
		)"
	KEYWORDS="-* ~amd64"
fi

DESCRIPTION="PlayStation 2 emulator"
HOMEPAGE="https://pcsx2.net/"

LICENSE="
	GPL-3+ Apache-2.0 BSD BSD-2 BSD-4 Boost-1.0 CC0-1.0 GPL-2+
	ISC LGPL-2.1+ LGPL-3+ MIT OFL-1.1 ZLIB public-domain"
SLOT="0"
IUSE="alsa cpu_flags_x86_sse4_1 lto test vulkan wayland"
REQUIRED_USE="cpu_flags_x86_sse4_1" # dies at runtime if no support
RESTRICT="!test? ( test )"

# dlopen: ffmpeg, qtsvg, vulkan-loader, wayland
COMMON_DEPEND="
	app-arch/xz-utils
	app-arch/zstd:=
	dev-cpp/rapidyaml:=
	dev-libs/libaio
	dev-libs/libfmt:=
	dev-libs/libzip:=[zstd]
	dev-cpp/simpleini
	dev-qt/qtbase:6[gui,network,widgets]
	dev-qt/qtsvg:6
	media-libs/libglvnd
	media-libs/libpng:=
	>=media-libs/libsdl2-2.0.22[haptic,joystick]
	media-libs/libsoundtouch:=
	media-video/ffmpeg:=
	net-libs/libpcap
	net-misc/curl
	sys-libs/zlib:=
	virtual/libudev:=
	x11-libs/libXrandr
	vulkan? ( media-libs/vulkan-loader )
	wayland? ( dev-libs/wayland )"
RDEPEND="
	${COMMON_DEPEND}
	>=games-emulation/pcsx2_patches-0_p20230917
"
DEPEND="
	${COMMON_DEPEND}
	x11-base/xorg-proto
	test? ( dev-cpp/gtest )"
BDEPEND="
	dev-qt/qttools:6[linguist]
	wayland? (
		dev-util/wayland-scanner
		kde-frameworks/extra-cmake-modules
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-unbundle.patch
	"${FILESDIR}"/${PN}-system-glslang.patch
	"${FILESDIR}"/${P}-cubeb-automagic.patch
	"${FILESDIR}"/${PN}-1.7.3773-lto.patch
	"${FILESDIR}"/${PN}-1.7.4667-flags.patch
	"${FILESDIR}"/${PN}-1.7.4795-rapidyaml-0.5.patch
	"${FILESDIR}"/${PN}-fmt-10.patch
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

		mkdir -p "${S}"/3rdparty/rapidyaml/rapidyaml/ext/c4core/src/c4/ext || die
		mv fast_float-${HASH_FASTFLOAT} \
			"${S}"/3rdparty/rapidyaml/rapidyaml/ext/c4core/src/c4/ext/fast_float || die

		rmdir "${S}"/3rdparty/rcheevos/rcheevos || die
		mv rcheevos-${HASH_RCHEEVOS} "${S}"/3rdparty/rcheevos/rcheevos || die

		if use vulkan; then
			rmdir "${S}"/3rdparty/{glslang/glslang,vulkan-headers} || die
			mv glslang-${HASH_GLSLANG} "${S}"/3rdparty/glslang/glslang || die
			mv Vulkan-Headers-${HASH_VULKAN} "${S}"/3rdparty/vulkan-headers || die
		fi
	fi
}

src_prepare() {
	cmake_src_prepare

	sed -e "/EmuFolders::AppRoot =/s|=.*|= \"${EPREFIX}/usr/share/${PN}\";|" \
		-i pcsx2/Pcsx2Config.cpp || die

	if [[ ${PV} != 9999 ]]; then
		sed -e '/set(PCSX2_GIT_TAG "")/s/""/"v'${PV}-gentoo'"/' \
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
}

src_configure() {
	if use vulkan; then
		# for bundled glslang (bug #858374)
		append-flags -fno-strict-aliasing
	fi

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=no
		-DDISABLE_BUILD_DATE=yes
		-DENABLE_TESTS=$(usex test)
		-DUSE_LINKED_FFMPEG=yes
		-DUSE_VTUNE=no
		-DUSE_VULKAN=$(usex vulkan)
		-DWAYLAND_API=$(usex wayland)
		-DX11_API=yes # fails if X libs are missing even if disabled

		# sse4.1 is the bare minimum required, -m is required at build time
		# (see PCSX2Base.h) and it dies if no support at runtime (AppInit.cpp)
		# https://github.com/PCSX2/pcsx2/pull/4329
		-DARCH_FLAG=-msse4.1

		# not packaged due to bug #885471, but still disable for no automagic
		-DCMAKE_DISABLE_FIND_PACKAGE_Libbacktrace=yes

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

	local replacing=
	if [[ ${REPLACING_VERSIONS##* } ]]; then
		if ver_test ${REPLACING_VERSIONS##* } -lt 1.6.1; then
			replacing=old
		elif ver_test ${REPLACING_VERSIONS##* } -lt 1.7.3773; then
			replacing=wx
		else
			replacing=any
		fi
	fi

	if [[ ${replacing} == old ]]; then
		elog
		elog ">=${PN}-1.7 has received several changes since <=${PN}-1.6.0, notably"
		elog "it is now a 64bit build using Qt6. Just-in-case it is recommended to"
		elog "backup your configs, save states, and memory cards before use."
		elog "The executable was also renamed from 'PCSX2' to 'pcsx2'."
	fi
}
