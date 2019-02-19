# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib cmake-utils git-r3

EGIT_REPO_URI="https://github.com/KhronosGroup/glslang.git"
SRC_URI=""

DESCRIPTION="Khronos reference front-end for GLSL and ESSL, and sample SPIR-V generator"
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/"

LICENSE="BSD"
SLOT="0"

DEPEND="dev-util/spirv-tools"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-shared-libs.patch" )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		)

	cmake-multilib_src_configure
	mkdir "${S}"/glslang/Public/glslang
	ln -s "${S}"/glslang/Public/ShaderLang.h "${S}"/glslang/Public/glslang/ShaderLang.h || die
}

src_install() {
	cmake-multilib_src_install

	# Match SPIRV-Tools
	insinto /usr/include/SPIRV
	doins SPIRV/spirv.hpp
}
