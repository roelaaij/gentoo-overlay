# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ROCM_VERSION=6.1.2
inherit git-r3 go-module rocm cuda cmake linux-info systemd toolchain-funcs

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models."
HOMEPAGE="https://ollama.com"
EGIT_REPO_URI="https://github.com/ollama/ollama.git"
LICENSE="MIT"
SLOT="0"

IUSE="cuda rocm vulkan"

declare -A CPU_FLAGS=(
	[avx]=AVX
	[avx2]=AVX2
	[avx_vnni]=AVX_VNNI
	[avx512f]=AVX512
	[avx512vbmi]=AVX512_VBMI
	[avx512_vnni]=AVX512_VNNI
	[avx512_bf16]=AVX512_BF16
	[fma3]=FMA
	[f16c]=F16C
	[amx_tile]=AMX_TILE
	[amx_int8]=AMX_INT8

)

CPU_FEATURES=$(printf "cpu_flags_x86_%s " "${!CPU_FLAGS[@]}")
IUSE+=" ${CPU_FEATURES[@]} blas mkl"

RDEPEND="
	acct-group/ollama
	acct-user/ollama
"
IDEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/go-1.21.0
	>=dev-build/cmake-3.24
	>=sys-devel/gcc-11.4.0
	blas? (
		!mkl? (
			virtual/blas
		)
		mkl? (
			sci-libs/mkl
		)
	)
	cuda? ( dev-util/nvidia-cuda-toolkit )
	rocm? (
		sci-libs/clblast
		dev-libs/rocm-opencl-runtime
	)
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
	acct-group/ollama
	acct-user/ollama[cuda?]
"

PATCHES=(
	${FILESDIR}/${PN}-optional-all-cpu.patch
)

pkg_pretend() {
	if use rocm; then
		ewarn "WARNING: AMD & Nvidia support in this ebuild are experimental"
		einfo "If you run into issues, especially compiling dev-libs/rocm-opencl-runtime"
		einfo "you may try the docker image here https://github.com/ROCm/ROCm-docker"
		einfo "and follow instructions here"
		einfo "https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html"
	fi
}

src_unpack() {
	git-r3_src_unpack
	go-module_live_vendor
}

src_prepare() {
	sed -iE "s|/usr/local/cuda-[12]{2}|/opt/cuda|g" llama/llama.go
	if use cuda; then
		cuda_src_prepare
	fi
	cmake_src_prepare
}

src_configure() {
	mycmakeargs+=(
		# backends end up in /usr/bin otherwise
		-DGGML_BACKEND_DL="yes"
		# TODO causes duplicate install warning but breaks detection otherwise ollama/issues/13614
		-DGGML_BACKEND_DIR="${EPREFIX}/usr/$(get_libdir)/${PN}"

		-DGGML_CPU_ALL_VARIANTS=OFF
		-DGGML_BLAS="$(usex blas)"
		"$(cmake_use_find_package vulkan Vulkan)"
	)

	if use rocm; then
		AMDGPU_TARGETS="$(get_amdgpu_flags)"
		mycmakeargs+=(
			-DAMDGPU_TARGETS="\"${AMDGPU_TARGETS::-1}\""
		)
	else
		mycmakeargs+=(
			-DCMAKE_HIP_COMPILER="NOTFOUND"
		)
	fi

	if use cuda; then
		mycmakeargs+=(
			-DCMAKE_CUDA_COMPILER=${EPREFIX}/opt/cuda/bin/nvcc
			-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)"/gcc
			-DCMAKE_CUDA_ARCHITECTURES=${CUDA_COMPUTE_CAPABILITIES//./}
		)
	else
		mycmakeargs+=(
			-DCMAKE_CUDA_COMPILER="NOTFOUND"
		)
	fi

	if use blas; then
		if use mkl; then
			mycmakeargs+=(
				-DGGML_BLAS_VENDOR="Intel10_64lp"
			)
		else
			mycmakeargs+=(
				-DGGML_BLAS_VENDOR="Generic"
			)
		fi
	fi

	for i in "${!CPU_FLAGS[@]}" ; do
		if [[ ${ABI} == amd64 || ${ABI} == x86 ]]; then
			use "cpu_flags_x86_${i}" && mycmakeargs+=("-DGGML_${CPU_FLAGS[$i]}=ON")
		fi
	done
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	VERSION=$(
		git describe --tags --first-parent --abbrev=7 --long --dirty --always \
		| sed -e "s/^v//g"
		assert
	)
	local EXTRA_GOFLAGS_LD=(
		# "-w" # disable DWARF generation
		# "-s" # disable symbol table
		"-X=github.com/ollama/ollama/version.Version=${VERSION}"
		"-X=github.com/ollama/ollama/server.mode=release"
	)
	GOFLAGS+=" '-ldflags=${EXTRA_GOFLAGS_LD[*]}'"

	ego build
}

src_install() {
	cmake_src_install

	dobin ollama

	newinitd "${FILESDIR}/ollama.init" "${PN}"
	newconfd "${FILESDIR}/ollama.confd" "${PN}"

	systemd_dounit "${FILESDIR}/ollama.service"
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners ollama:ollama /var/log/ollama
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		einfo "Quick guide:"
		einfo "\tollama serve"
		einfo "\tollama run llama3:70b"
		einfo
		einfo "See available models at https://ollama.com/library"
	fi

	if use cuda ; then
		einfo "When using cuda the user running ${PN} has to be in the video group or it won't detect devices."
		einfo "The ebuild ensures this for user ${PN} via acct-user/${PN}[cuda]"
	fi
}
