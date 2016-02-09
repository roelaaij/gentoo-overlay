# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: games-emulation/ps2emu-zerogs-9999.ebuild,v 1.1 2014/06/20 08:30:00 frostwork Exp $

EAPI=5

WX_GTK_VER="3.0"

inherit games cmake-utils git-2

DESCRIPTION="zerogs plugin for pcsx2"
HOMEPAGE="http://www.pcsx2.net"
EGIT_REPO_URI="https://github.com/PCSX2/pcsx2.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

DEPEND="dev-cpp/sparsehash
		media-libs/glew
		media-gfx/nvidia-cg-toolkit
		virtual/opengl
		x11-libs/libICE
		x11-libs/libX11
		x11-libs/libXext"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e "s:EXTRA_PLUGINS FALSE:EXTRA_PLUGINS TRUE:g" -i cmake/BuildParameters.cmake
	sed -i -e "s:add_subdirectory(3rdparty)::g" -i CMakeLists.txt
	sed -i -e "s:INSTALL(FILES:#INSTALL(FILES:g" -i CMakeLists.txt
	sed -i -e "s:add_subdirectory(locales)::g" -i CMakeLists.txt
	sed -i -e "s:add_subdirectory(tools)::g" -i CMakeLists.txt
	sed -i -e "s:add_subdirectory(common/src/Utilities)::g" -i CMakeLists.txt
	sed -i -e "s:add_subdirectory(common/src/x86emitter)::g" -i CMakeLists.txt
	sed -i -e "s:pcsx2_core TRUE:pcsx2_core FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:CDVDiso TRUE:CDVDiso FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:CDVDlinuz TRUE:CDVDlinuz FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:CDVDnull TRUE:CDVDnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:dev9null TRUE:dev9null FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:GSnull TRUE:GSnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:GSdx TRUE:GSdx FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:FWnull TRUE:FWnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:zzogl TRUE:zzogl FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:PadNull TRUE:PadNull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:onepad TRUE:onepad FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:zeropad TRUE:zeropad FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:SPU2null TRUE:SPU2null FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:spu2-x TRUE:spu2-x FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:zerospu2 TRUE:zerospu2 FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:USBnull TRUE:USBnull FALSE:g" -i cmake/SelectPcsx2Plugins.cmake
	sed -i -e "s:#[\t]add_subdirectory(zerogs):add_subdirectory(zerogs):g" -i plugins/CMakeLists.txt
	sed -i -e "s:#include \"zlib/zlib.h\":#include <zlib.h>:g" -i plugins/zerogs/opengl/zpipe.cpp

	epatch_user
}

src_configure() {
	multilib_toolchain_setup x86
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
		${cg_config}
		"
	cmake-utils_src_configure
}

src_install() {
	insinto $(games_get_libdir)/pcsx2
	doins bin/plugins/libzerogs.so || die
	prepgamesdirs
}
