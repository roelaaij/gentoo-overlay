# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=Vulkan-Utility-Libraries
inherit cmake-multilib

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/${MY_PN}.git"
	EGIT_SUBMODULES=()
	inherit git-r3
else
	SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/sdk-${PV}.0.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~x86"
	S="${WORKDIR}"/${MY_PN}-sdk-${PV}.0
fi

DESCRIPTION="Vulkan Utility Libraries"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Vulkan-Utility-Libraries"

LICENSE="Apache-2.0"
SLOT="0"

BDEPEND=">=dev-build/cmake-3.10.2"
RDEPEND=""
DEPEND="${RDEPEND}
	~dev-util/vulkan-headers-${PV}
"

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_C_FLAGS="${CFLAGS} -DNDEBUG"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS} -DNDEBUG"
		-DCMAKE_SKIP_RPATH=ON
		-DVUL_WERROR=OFF
		-DBUILD_TESTS=OFF
	)
	cmake_src_configure
}
