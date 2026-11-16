# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
ROCM_VERSION=7.2  # controls AMDGPU_TARGETS
ROCM_MIN_VERSION=6.1  # src/ggml-hip/CMakeList.txt

inherit cmake cuda flag-o-matic python-any-r1 rocm toolchain-funcs

DESCRIPTION="Tensor library for machine learning"
HOMEPAGE="https://ggml.ai/"
SRC_URI="https://github.com/ggml-org/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"

X86_CPU_FLAGS=(
	amx_bf16
	amx_int8
	amx_tile
	avx
	avx_vnni
	avx2
	avx512_bf16
	avx512bw
	avx512f
	avx512vbmi
	avx512_vnni
	bmi2
	fma3
	f16c
	sse4_2
)
CPU_FLAGS=( "${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}" )
IUSE="blas flexiblas ${CPU_FLAGS[*]} cuda opencl openmp rocm rpc test vulkan wmma"

REQUIRED_USE="
	rocm? ( ${ROCM_REQUIRED_USE} )
	wmma? ( rocm )
"

unset X86_CPU_FLAGS CPU_FLAGS

RESTRICT="!test? ( test )"

# Should be >=sci-libs/hipBLAS-${ROCM_VERSION}[${ROCM_USEDEP}]
# But pkgcheck can't elaborate that
RDEPEND="
	blas? ( virtual/cblas[flexiblas=] )
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
	opencl? (
		dev-libs/opencl-icd-loader
	)
	vulkan? ( media-libs/vulkan-loader )
	rocm? (
		>=dev-util/hip-${ROCM_MIN_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_MIN_VERSION}:=
		>=sci-libs/rocBLAS-${ROCM_MIN_VERSION}:=
		wmma? (
			>=sci-libs/rocWMMA-${ROCM_VERSION}:=
		)
	)
"
DEPEND="${RDEPEND}
	opencl? ( dev-util/opencl-headers )
	vulkan? ( dev-util/vulkan-headers )
"
BDEPEND="
	opencl? ( ${PYTHON_DEPS} )
	vulkan? ( media-libs/shaderc )
"

DOCS=( AUTHORS CONTRIBUTING.md docs/gguf.md README.md )

PATCHES=(
	"${FILESDIR}"/${PN}-0.28.0-llvm-23.patch
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	if use cuda && [[ -z ${CUDA_ARCHITECTURES} ]]; then
		einfo "CUDA_ARCHITECTURES wasn't set, so ggml builds its full default set of"
		einfo "CUDA compute capabilities (75/80/86/89/90/120a/121a)."
		einfo "Set it to your GPU's compute capability to skip unused targets, e.g."
		einfo 'CUDA_ARCHITECTURES="75-real" (several are separated with ";": "75-real;80-real")'
		einfo "  find: nvidia-smi --query-gpu=compute_cap --format=csv,noheader"
		einfo "  suffixes: 75 (PTX+SASS), 75-real (SASS only), 75-virtual (PTX only)"
	fi
}

pkg_setup() {
	if use opencl; then
		python-any-r1_pkg_setup
	fi

	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare

	if use cuda; then
		cuda_src_prepare
		filter-lto #bug 983121
	fi
}

src_configure() {
	local mycmakeargs=(
		-DGGML_BUILD_EXAMPLES=OFF
		-DGGML_NATIVE=OFF
		-DGGML_HIP_MMQ_MFMA=OFF
		-DGGML_LTO=OFF # only adds flags
		-DGGML_CCACHE=OFF

		# CPU Flags
		-DGGML_AMX_BF16=$(usex cpu_flags_x86_amx_bf16)
		-DGGML_AMX_INT8=$(usex cpu_flags_x86_amx_int8)
		-DGGML_AMX_TILE=$(usex cpu_flags_x86_amx_tile)
		-DGGML_AVX=$(usex cpu_flags_x86_avx)
		-DGGML_AVX_VNNI=$(usex cpu_flags_x86_avx_vnni)
		-DGGML_AVX2=$(usex cpu_flags_x86_avx2)
		-DGGML_AVX512_BF16=$(usex cpu_flags_x86_avx512_bf16)
		-DGGML_AVX512_VBMI=$(usex cpu_flags_x86_avx512vbmi)
		-DGGML_AVX512_VNNI=$(usex cpu_flags_x86_avx512_vnni)
		-DGGML_BMI2=$(usex cpu_flags_x86_bmi2)
		-DGGML_FMA=$(usex cpu_flags_x86_fma3)
		-DGGML_F16C=$(usex cpu_flags_x86_f16c)
		-DGGML_SSE42=$(usex cpu_flags_x86_sse4_2)

		-DGGML_RPC=$(usex rpc)
		-DGGML_BLAS=$(usex blas)
		-DGGML_CUDA=$(usex cuda)
		-DGGML_HIP=$(usex rocm)
		-DGGML_HIP_MMQ_MFMA=$(usex wmma)
		-DGGML_HIP_ROCWMMA_FATTN=$(usex wmma)
		-DGGML_OPENMP=$(usex openmp)
		-DGGML_VULKAN=$(usex vulkan)

		-DGGML_BUILD_TESTS=$(usex test)
	)

	# Enable AVX512 if ANY of the avx512 flags are present
	if use cpu_flags_x86_avx512f || use cpu_flags_x86_avx512bw; then
		mycmakeargs+=( -DGGML_AVX512=ON )
	else
		mycmakeargs+=( -DGGML_AVX512=OFF )
	fi

	if use blas; then
		if use flexiblas; then
			mycmakeargs+=( -DGGML_BLAS_VENDOR=FlexiBLAS )
		else
			mycmakeargs+=(
				-DGGML_BLAS_VENDOR=Generic
				# https://cmake.org/cmake/help/latest/module/FindBLAS.html
				-DBLA_PREFER_PKGCONFIG=ON
				-DBLA_PKGCONFIG_BLAS=cblas
			)
		fi
	fi

	if use cuda; then
		cuda_add_sandbox -w
		addpredict "/dev/char/"
		cuda_sanitize
		mycmakeargs+=(
			-DCMAKE_CUDA_FLAGS="${NVCCFLAGS}"
		)

		# CUDA_ARCHITECTURES: restrict CUDA compute capabilities (see pkg_pretend)
		if [[ -n ${CUDA_ARCHITECTURES} ]]; then
			mycmakeargs+=( -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCHITECTURES}" )
		fi
	fi

	if use rocm; then
		# Changing compiler with rocm_use_{hipcc,clang} is not necessary
		# Pass HIP compatible flags using dedicated CMake variables
		mycmakeargs+=(
			-DGPU_TARGETS=$(get_amdgpu_flags)
			-DCMAKE_HIP_FLAGS="$(test-flags-HIPCXX ${CXXFLAGS})"
			# cmake.eclass clears per-build-type flags for C/CXX only; drop CMake's "-O2 -g -DNDEBUG" for HIP
			-DCMAKE_HIP_FLAGS_${CMAKE_BUILD_TYPE^^}=
		)
	fi

	if use cuda && use rocm; then
		mycmakeargs+=( -DGGML_BACKEND_DL=ON )
	else
		mycmakeargs+=( -DGGML_BACKEND_DL=OFF )
	fi

	cmake_src_configure
}

src_test() {
	local CMAKE_SKIP_TESTS=()
	if use rocm; then
		check_amdgpu
		if use amdgpu_targets_gfx1031; then  # raise CUDA errors
			CMAKE_SKIP_TESTS+=(
				test-backend-ops
				test-opt
			)
		fi
	fi
	cmake_src_test
}
