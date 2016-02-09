# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: games-emulation/ps2emu-zzogl-9999.ebuild,v 1.1 2014/06/20 08:30:00 frostwork Exp $

EAPI=5

WX_GTK_VER="3.0"

inherit games cmake-utils git-2 wxwidgets

DESCRIPTION="zzogl plugin for pcsx2"
HOMEPAGE="http://www.pcsx2.net"
EGIT_REPO_URI="https://github.com/PCSX2/pcsx2.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug cg"
if use amd64; then
	ABI="x86"
fi
if use debug; then
	CMAKE_BUILD_TYPE="Debug"
else
	CMAKE_BUILD_TYPE="Release"
fi

DEPEND="dev-cpp/sparsehash
		app-arch/bzip2
		sys-libs/zlib
		media-libs/alsa-lib
		media-libs/glew
		media-libs/libsdl
		media-libs/portaudio
		cg? ( media-gfx/nvidia-cg-toolkit )
		virtual/jpeg
		virtual/opengl
		x11-libs/gtk+:3
		x11-libs/libICE
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/wxGTK:3.0[X]"

RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e "s:EXTRA_PLUGINS FALSE:EXTRA_PLUGINS TRUE:g" -i cmake/BuildParameters.cmake
	sed -e "s:add_subdirectory(3rdparty)::g" -i CMakeLists.txt
	sed -e "s:INSTALL(FILES:#INSTALL(FILES:g" -i CMakeLists.txt
	sed -e "s:add_subdirectory(locales)::g" -i CMakeLists.txt
	sed -e "s:add_subdirectory(tools)::g" -i CMakeLists.txt
#	sed -e "s:add_subdirectory(common/src/Utilities)::g" -i CMakeLists.txt
	sed -e "s:add_subdirectory(common/src/x86emitter)::g" -i CMakeLists.txt
	sed -e "s:pcsx2_core TRUE:pcsx2_core FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:CDVDiso TRUE:CDVDiso FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:CDVDlinuz TRUE:CDVDlinuz FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:CDVDnull TRUE:CDVDnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:dev9null TRUE:dev9null FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:FWnull TRUE:FWnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:GSdx TRUE:GSdx FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:zerogs TRUE:zerogs FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:GSnull TRUE:GSnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:PadNull TRUE:PadNull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:onepad TRUE:onepad FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:zeropad TRUE:zeropad FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:SPU2null TRUE:SPU2null FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:spu2-x TRUE:spu2-x FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:zerospu2 TRUE:zerospu2 FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -e "s:USBnull TRUE:USBnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake

	epatch_user
}

src_configure() {
	multilib_toolchain_setup x86
	wxgtk_config=""
	cg_config=""
	if use amd64; then
		# tell cmake to use 32 bit library
		wxgtk_config="-DwxWidgets_CONFIG_EXECUTABLE=/usr/bin/wx-config-3.0-x86"
		cg_config="-DCG_LIBRARY=/opt/nvidia-cg-toolkit/lib32/libCg.so
					-DCG_GL_LIBRARY=/opt/nvidia-cg-toolkit/lib32/libCgGL.so"
	fi

	mycmakeargs="
		-DCMAKE_BUILD_TYPE=Release
		-DPACKAGE_MODE=1
		-DPLUGIN_DIR=$(games_get_libdir)/pcsx2
		-DPLUGIN_DIR_COMPILATION=$(games_get_libdir)/pcsx2
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_LIBRARY_PATH=$(games_get_libdir)/pcsx2
		-DGTK3_API=TRUE
		$(cmake-utils_use !cg GLSL_API)
		${wxgtk_config}
		${cg_config}
		"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install DESTDIR=${D}
	prepgamesdirs
}
