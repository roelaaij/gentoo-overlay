# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

DISTUTILS_OPTIONAL=1

inherit cmake-utils distutils-r1 git-r3 cuda

DESCRIPTION="Datasets, Transforms and Models specific to Computer Vision"
HOMEPAGE="https://github.com/pytorch/vision"
EGIT_REPO_URI="https://github.com/pytorch/vision"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS=""

IUSE="cuda ffmpeg +python"

REQUIRED_USE="ffmpeg? ( python )"

DEPEND="
	cuda? ( dev-util/nvidia-cuda-toolkit:0= )
	ffmpeg? ( virtual/ffmpeg )
	python? (
		dev-python/setuptools[${PYTHON_USEDEP}]
		sci-libs/scipy
		>=dev-python/pillow-4.1.1[${PYTHON_USEDEP}]
	)
	=sci-libs/pytorch-9999[python?,cuda?]
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/0001-Control-support-of-ffmpeg-0.6.0.patch"
	"${FILESDIR}/0001-Don-t-detect-CUDA-if-FORCE_CUDA-is-present.patch"
)

src_prepare() {
	cmake-utils_src_prepare

	if use python; then
		distutils-r1_src_prepare
	fi
	unset NVCCFLAGS
}

src_configure() {

	local mycmakeargs=()

	if use cuda; then
		cuda_host_compiler="$(cuda_gccdir)/$(tc-getCC)"
		if [[ *$(gcc-version)* != $(cuda-config -s) ]]; then
			ewarn "pytorch is being built with Nvidia CUDA support. Your default compiler"
			ewarn "version is not supported by the currently installed CUDA. pytorch will"
			ewarn "be compiled using CUDA host compiler: ${cuda_host_compiler}"
		fi

		if [[ -z "$CUDA_COMPUTE_CAPABILITIES" ]]; then
			ewarn "WARNING: pytorch is being built with its default CUDA compute capabilities: All."
			ewarn "These may not be optimal for your GPU."
			ewarn ""
			ewarn "To configure pytorch with the CUDA compute capability that is optimal for your GPU,"
			ewarn "set CUDA_COMPUTE_CAPABILITIES in your make.conf, and re-emerge tensorflow."
			ewarn "For example, to use CUDA capability 7.5 & 3.5, add: CUDA_COMPUTE_CAPABILITIES=7.5,3.5"
			ewarn ""
			ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
			ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
			CUDA_COMPUTE_CAPABILITIES=All
		fi
		mycmakeargs+=(
			-DCUDA_HOST_COMPILER=${cuda_host_compiler}
			-DTORCH_CUDA_ARCH_LIST=${CUDA_COMPUTE_CAPABILITIES/,/;}
		)
	fi

	cmake-utils_src_configure

	if use python; then
		FORCE_CUDA=$(usex cuda 1 0) \
		TORCH_CUDA_ARCH_LIST=${CUDA_COMPUTE_CAPABILITIES/,/;} \
		NVCC_FLAGS="-ccbin=$(cuda_gccdir)/$(tc-getCC)" \
		CUDA_HOME=$(usex cuda ${CUDA_HOME} "") \
		ENABLE_FFMPEG=$(usex ffmpeg 1 0) \
		distutils-r1_src_configure
	fi
}

src_compile() {
	cmake-utils_src_compile

	if use python; then
		FORCE_CUDA=$(usex cuda 1 0) \
		TORCH_CUDA_ARCH_LIST=${CUDA_COMPUTE_CAPABILITIES/,/;} \
		NVCC_FLAGS="-ccbin=$(cuda_gccdir)/$(tc-getCC)" \
		CUDA_HOME=$(usex cuda ${CUDA_HOME} "") \
		ENABLE_FFMPEG=$(usex ffmpeg 1 0) \
		MAKEOPTS="-j1" \
		distutils-r1_src_compile
	fi
}

src_install() {
	cmake-utils_src_install

	if use python; then
		FORCE_CUDA=$(usex cuda 1 0) \
		TORCH_CUDA_ARCH_LIST=${CUDA_COMPUTE_CAPABILITIES/,/;} \
		NVCC_FLAGS="-ccbin=$(cuda_gccdir)/$(tc-getCC)" \
		CUDA_HOME=$(usex cuda ${CUDA_HOME} "") \
		ENABLE_FFMPEG=$(usex ffmpeg 1 0) \
		distutils-r1_src_install
	fi
}
