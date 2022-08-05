# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib git-r3

DESCRIPTION="SPIRV-Cross is a practical tool and library for performing reflection on SPIR-V and disassembling SPIR-V back to high level languages."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Cross"
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Cross.git"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"

RDEPEND=""
DEPEND="dev-util/spirv-headers
		dev-util/glslang"

src_configure() {
	# Disable building the examples and install their source manually later
	local mycmakeargs=(
		-DSPIRV_CROSS_SHARED=ON
	)
	cmake-multilib_src_configure
}
