# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=Vulkan-ValidationLayers
PYTHON_COMPAT=( python3_{9..12} )
inherit cmake-multilib python-any-r1

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/${MY_PN}.git"
	EGIT_SUBMODULES=()
	inherit git-r3
else
	SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/sdk-${PV}.0.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~x86"
	S="${WORKDIR}"/${MY_PN}-sdk-${PV}.0
fi

DESCRIPTION="Vulkan Validation Layers"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-ValidationLayers"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="wayland X generate"

BDEPEND=">=dev-build/cmake-3.10.2"
RDEPEND="~dev-util/spirv-tools-9999:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-cpp/robin-hood-hashing-3.11.5
	~dev-util/glslang-${PV}:=[${MULTILIB_USEDEP}]
	~dev-util/vulkan-headers-${PV}
	~media-libs/vulkan-utility-libraries-${PV}
	wayland? ( dev-libs/wayland:=[${MULTILIB_USEDEP}] )
	X? (
		x11-libs/libX11:=[${MULTILIB_USEDEP}]
		x11-libs/libXrandr:=[${MULTILIB_USEDEP}]
	)
"

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_C_FLAGS="${CFLAGS} -DNDEBUG"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS} -DNDEBUG"
		-DCMAKE_SKIP_RPATH=ON
		-DBUILD_LAYER_SUPPORT_FILES=OFF
		-DBUILD_WERROR=OFF
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DBUILD_TESTS=OFF
		-DVULKAN_HEADERS_INSTALL_DIR="${ESYSROOT}/usr"
		-DSPIRV_HEADERS_INSTALL_DIR="${ESYSROOT}/usr"
		-DVVL_CODEGEN=$(usex generate)
	)
	if [ use generate ]; then
		mycmakeargs+=(
			-DPython3_EXECUTABLE="${PYTHON}"
		)
	fi

	cmake_src_configure
}

multilib_src_compile() {
	use generate && cmake_build vvl_codegen
	cmake_src_compile
}

multilib_src_install_all() {
	find "${ED}" -type f -name \*.a -delete || die
}
