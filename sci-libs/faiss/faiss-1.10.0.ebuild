# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda

DESCRIPTION="Faiss: a library for efficient similarity search and clustering of dense vectors"
HOMEPAGE="https://github.com/facebookresearch/faiss"
SRC_URI="https://github.com/facebookresearch/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
declare -A CPU_FLAGS=(
	[avx2]=avx2
	[avx512f]=avx512
)

CPU_FEATURES=$(printf "cpu_flags_x86_%s " "${!CPU_FLAGS[@]}")
IUSE+=" ${CPU_FEATURES[@]} test cuda mkl"

RDEPEND="
	dev-libs/libfmt
	mkl? ( sci-libs/mkl )
	cuda? ( dev-util/nvidia-cuda-toolkit )
"
DEPEND="${RDEPEND}"
BDEPEND="
	test? ( dev-cpp/gtest )
"
RESTRICT="!test? ( test )"

PATCHES=(
	${FILESDIR}/${PN}-shared-libs.patch
)

src_prepare() {
	if use cuda; then
		cuda_src_prepare
	fi
	cmake_src_prepare
}

src_configure() {
	mycmakeargs+=(
		-DBUILD_TESTING=$(usex test)
		-DFAISS_ENABLE_CUVS=OFF
		-DFAISS_ENABLE_PYTHON=OFF
		-DFAISS_ENABLE_GPU=$(usex cuda)
		-DUSE_SYSTEM_GTEST=ON
	)
	if use "cpu_flags_x86_avx512f"; then
		mycmakeargs+=(-DFAISS_OPT_LEVEL=avx512)
	elif use "cpu_flags_x86_avx2"; then
		mycmakeargs+=(-DFAISS_OPT_LEVEL=avx2)
	fi

	if use cuda; then
		mycmakeargs+=(
			-DCMAKE_CUDA_COMPILER=${EPREFIX}/opt/cuda/bin/nvcc
			-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)"/gcc
			-DCMAKE_CUDA_ARCHITECTURES="${CUDA_COMPUTE_CAPABILITIES//./}"
		)
		if [[ "${FEATURES}" == *"ccache"* ]]; then
			mycmakeargs+=(
				-DCMAKE_CUDA_COMPILER_LAUNCHER=ccache
			)
		fi
	fi

	cmake_src_configure
}
