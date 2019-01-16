# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-multilib cmake-utils git-r3

DESCRIPTION="SPIRV-Cross is a practical tool and library for performing reflection on SPIR-V and disassembling SPIR-V back to high level languages."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Cross"
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Cross.git"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"

RDEPEND=""
DEPEND="dev-util/spirv-headers
		dev-util/glslang"

PATCHES=( "${FILESDIR}/proper-libdir.patch" )
