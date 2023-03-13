# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda

DESCRIPTION="A collection of CUDA C++ template abstractions for implementing high-performance matrix-matrix multiplication (GEMM)"
HOMEPAGE="https://github.com/NVIDIA/${PN}"
SRC_URI="https://github.com/NVIDIA/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
"
DEPEND=">=dev-util/nvidia-cuda-toolkit-11.4"

src_prepare() {
	cuda_add_sandbox
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCUTLASS_ENABLE_HEADERS_ONLY=ON
		-DCUTLASS_ENABLE_EXAMPLES=OFF
		-DCUTLASS_ENABLE_TOOLS=OFF
		-DCUTLASS_ENABLE_TESTS=OFF
		-DCMAKE_CUDA_COMPILER="${EPREFIX}/opt/cuda/bin/nvcc"
		-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)/$(tc-getCC)"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	rm -r ${D}/usr/test || die
}
