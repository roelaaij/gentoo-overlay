# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ROCM_VERSION=6.1.2
inherit git-r3 go-module rocm cuda

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models."
HOMEPAGE="https://ollama.com"
EGIT_REPO_URI="https://github.com/ollama/ollama.git"
LICENSE="MIT"
SLOT="0"

IUSE="nvidia amd"

CPU_FLAGS=(
		avx
		avx2
		avx512f
		avx512vbmi
		avx512_vnni
		avx512_bf16
)

CPU_FEATURES=$(printf "cpu_flags_x86_%s " "${CPU_FLAGS[@]}")
IUSE+=" ${CPU_FEATURES[*]%:*}"

RDEPEND="
	acct-group/ollama
	acct-user/ollama
"
IDEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/go-1.21.0
	>=dev-build/cmake-3.24
	>=sys-devel/gcc-11.4.0
	nvidia? ( dev-util/nvidia-cuda-toolkit )
	amd? (
		sci-libs/clblast
		dev-libs/rocm-opencl-runtime
	)
"

PATCHES=(
	${FILESDIR}/${PN}-amd-igpu.patch
	${FILESDIR}/${PN}-runners-libexec.patch
)

pkg_pretend() {
	if use amd; then
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
	cuda_src_prepare
	default
}

src_compile() {
	VERSION=$(
		git describe --tags --first-parent --abbrev=7 --long --dirty --always \
		| sed -e "s/^v//g"
		assert
	)
	export GOFLAGS="'-ldflags=-w -s \"-X=github.com/ollama/ollama/version.Version=${VERSION}\"'"
	if use amd; then
		AMDGPU_TARGETS="$(get_amdgpu_flags)"
		ROCM_MAKE_ARGS=(
			HIP_PATH=${EPREFIX}/usr
			HIP_LIB_DIR=${EPREFIX}/usr/lib64
			HIP_ARCHS_COMMON="${AMDGPU_TARGETS//;/ }" HIP_ARCHS_LINUX=
		)
	fi

	if use nvidia; then
		NVCC_CCBIN="$(cuda_gccdir)"
		export NVCC_CCBIN
		einfo "NVCC_CCBIN ${NVCC_CCBIN}"
		CUDA_MAKE_ARGS=(
			CUDA_12_PATH=${EPREFIX}/opt/cuda
			CUDA_ARCHITECTURES=${CUDA_COMPUTE_CAPABILITIES//./}
			GPU_PATH_ROOT_LINUX=${EPREFIX}/opt/cuda
		)
	fi

	for i in "${CPU_FLAGS[@]}" ; do
		if [[ ${ABI} == amd64 || ${ABI} == x86 ]]; then
			# These are merged into one flag internally
			case "${i}" in
				avx512f)
					value="avx512"
					;;
				*)
					value=${i/_/}
					;;
			esac
			use "cpu_flags_x86_${i}" && CUSTOM_CPU_FLAGS="${CUSTOM_CPU_FLAGS:+$CUSTOM_CPU_FLAGS,}$value"
		fi
	done

	emake "${CUSTOM_CPU_FLAGS:+CUSTOM_CPU_FLAGS=${CUSTOM_CPU_FLAGS}}" ${CUDA_MAKE_ARGS[@]} ${ROCM_MAKE_ARGS[@]}

	ego build .
}

src_install() {
	dobin ollama

	# Install runners and runner libraries
	for runner_type in `ls llama/build/linux-${ABI}/runners`
	do
		exeinto ${EPREFIX}/usr/libexec/ollama/runners/${runner_type}
		doexe llama/build/linux-${ABI}/runners/${runner_type}/ollama_llama_server
		insinto ${EPREFIX}/usr/libexec/ollama/runners/${runner_type}
		doins llama/build/linux-${ABI}/runners/${runner_type}/libggml_*.so
	done

	doinitd "${FILESDIR}"/ollama
}

pkg_preinst() {
	keepdir /var/log/ollama
	fowners ollama:ollama /var/log/ollama
}

pkg_postinst() {
	einfo "Quick guide:"
	einfo "ollama serve"
	einfo "ollama run llama3:70b"
	einfo "See available models at https://ollama.com/library"
}
