# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_SETUPTOOLS=manual
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_SINGLE_IMPL=1

PYTHON_COMPAT=( python3_{8,9,10} )

inherit distutils-r1 cmake cuda prefix

DESCRIPTION="An open source machine learning framework"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
https://github.com/google/benchmark/archive/e991355c02b93fe17713efe04cbc2e278e00fdbd.tar.gz -> benchmark-e991355c02b93fe17713efe04cbc2e278e00fdbd.tar.gz
https://github.com/pytorch/cpuinfo/archive/63b25457.tar.gz -> cpuinfo-63b25457.tar.gz
https://github.com/NVlabs/cub/archive/d106ddb991a56c3df1b6d51b2409e36ba8181ce4.tar.gz -> cub-d106ddb991a56c3df1b6d51b2409e36ba8181ce4.tar.gz
https://github.com/pytorch/fbgemm/archive/7588d9d804826b428fc0e4fd418e9cc3f7a72e52.tar.gz -> fbgemm-7588d9d804826b428fc0e4fd418e9cc3f7a72e52.tar.gz
https://github.com/asmjit/asmjit/archive/d0d14ac774977d0060a351f66e35cb57ba0bf59c.tar.gz -> asmjit-d0d14ac774977d0060a351f66e35cb57ba0bf59c.tar.gz
https://github.com/pytorch/cpuinfo/archive/5916273f79a21551890fd3d56fc5375a78d1598d.tar.gz -> cpuinfo-5916273f79a21551890fd3d56fc5375a78d1598d.tar.gz
https://github.com/google/googletest/archive/0fc5466d.tar.gz -> googletest-0fc5466d.tar.gz
https://github.com/fmtlib/fmt/archive/cd4af11efc9c622896a3e4cb599fa28668ca3d05.tar.gz -> fmt-cd4af11efc9c622896a3e4cb599fa28668ca3d05.tar.gz
https://github.com/houseroad/foxi/archive/c278588e34e535f0bb8f00df3880d26928038cad.tar.gz -> foxi-c278588e34e535f0bb8f00df3880d26928038cad.tar.gz
https://github.com/Maratyszcza/FP16/archive/4dfe081cf6bcd15db339cf2680b9281b8451eeb3.tar.gz -> FP16-4dfe081cf6bcd15db339cf2680b9281b8451eeb3.tar.gz
https://github.com/Maratyszcza/FXdiv/archive/b408327ac2a15ec3e43352421954f5b1967701d1.tar.gz -> FXdiv-b408327ac2a15ec3e43352421954f5b1967701d1.tar.gz
https://github.com/google/gemmlowp/archive/3fb5c176.tar.gz -> gemmlowp-3fb5c176.tar.gz
https://github.com/facebookincubator/gloo/archive/c22a5cfba94edf8ea4f53a174d38aa0c629d070f.tar.gz -> gloo-c22a5cfba94edf8ea4f53a174d38aa0c629d070f.tar.gz
https://github.com/google/googletest/archive/e2239ee6043f73722e7aa812a459f54a28552929.tar.gz -> googletest-e2239ee6043f73722e7aa812a459f54a28552929.tar.gz
https://github.com/intel/ideep/archive/9ca27bbfd88fa1469cbf0467bd6f14cd1738fa40.tar.gz -> ideep-9ca27bbfd88fa1469cbf0467bd6f14cd1738fa40.tar.gz
https://github.com/intel/mkl-dnn/archive/5ef631a0.tar.gz -> mkl-dnn-5ef631a0.tar.gz
cuda? ( https://github.com/NVIDIA/nccl/archive/033d7995.tar.gz -> nccl-033d7995.tar.gz )
https://github.com/Maratyszcza/NNPACK/archive/c07e3a0400713d546e0dea2d5466dd22ea389c73.tar.gz -> NNPACK-c07e3a0400713d546e0dea2d5466dd22ea389c73.tar.gz
https://github.com/onnx/onnx/archive/a82c6a70.tar.gz -> onnx-a82c6a70.tar.gz
https://github.com/onnx/onnx-tensorrt/archive/c153211418a7c57ce071d9ce2a41f8d1c85a878f.tar.gz -> onnx-tensorrt-c153211418a7c57ce071d9ce2a41f8d1c85a878f.tar.gz
https://github.com/onnx/onnx/archive/29e7aa7048809784465d06e897f043a4600642b2.tar.gz -> onnx-29e7aa7048809784465d06e897f043a4600642b2.tar.gz
https://github.com/google/benchmark/archive/e776aa02.tar.gz -> benchmark-e776aa02.tar.gz
https://github.com/google/benchmark/archive/5b7683f4.tar.gz -> benchmark-5b7683f4.tar.gz
https://github.com/google/googletest/archive/5ec7f0c4.tar.gz -> googletest-5ec7f0c4.tar.gz
https://github.com/Maratyszcza/psimd/archive/072586a71b55b7f8c584153d223e95687148a90.tar.gz -> psimd-072586a71b55b7f8c584153d223e95687148a90.tar.gz
https://github.com/Maratyszcza/pthreadpool/archive/a134dd5d4cee80cce15db81a72e7f929d71dd413.tar.gz -> pthreadpool-a134dd5d4cee80cce15db81a72e7f929d71dd413.tar.gz
https://github.com/Maratyszcza/PeachPy/archive/07d8fde8ac45d7705129475c0f94ed8925b93473.tar.gz -> PeachPy-07d8fde8ac45d7705129475c0f94ed8925b93473.tar.gz
https://github.com/pytorch/QNNPACK/archive/7d2a4e9931a82adc3814275b6219a03e24e36b4c.tar.gz -> QNNPACK-7d2a4e9931a82adc3814275b6219a03e24e36b4c.tar.gz
https://github.com/shibatch/sleef/archive/e0a003ee838b75d11763aa9c3ef17bf71a725bff.tar.gz -> sleef-e0a003ee838b75d11763aa9c3ef17bf71a725bff.tar.gz
https://github.com/pytorch/tensorpipe/archive/d2aa3485e8229c98891dfd604b514a39d45a5c99.tar.gz -> tensorpipe-d2aa3485e8229c98891dfd604b514a39d45a5c99.tar.gz
https://github.com/google/googletest/archive/2fe3bd99.tar.gz -> googletest-2fe3bd99.tar.gz
https://github.com/google/libnop/archive/aa95422e.tar.gz -> libnop-aa95422e.tar.gz
https://github.com/libuv/libuv/archive/48e04275332f5753427d21a52f17ec6206451f2c.tar.gz -> libuv-48e04275332f5753427d21a52f17ec6206451f2c.tar.gz
https://github.com/google/XNNPACK/archive/79cd5f9e18ad0925ac9a050b00ea5a36230072db.tar.gz -> XNNPACK-79cd5f9e18ad0925ac9a050b00ea5a36230072db.tar.gz
https://github.com/pytorch/kineto/archive/879a203d9bf554e95541679ddad6e0326f272dc1.tar.gz -> kineto-879a203d9bf554e95541679ddad6e0326f272dc1.tar.gz
https://github.com/driazati/breakpad/archive/edbb99f95c75be27d038fffb1d969cdacf705db2.tar.gz -> breakpad-edbb99f95c75be27d038fffb1d969cdacf705db2.tar.gz
https://github.com/mikey/linux-syscall-support/archive/e1e7b0ad8ee99a875b272c8e33e308472e897660.tar.gz -> lss-e1e7b0ad8ee99a875b272c8e33e308472e897660.tar.gz
"


LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="asan atlas cuda doc eigen +fbgemm ffmpeg gflags glog +gloo leveldb lmdb mkl +mkldnn mpi namedtensor +nnpack numa +numpy +observers openblas opencl opencv +openmp +python +qnnpack redis rocm static tbb test tools zeromq"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	numpy? ( python )
	atlas? ( !eigen !mkl !openblas )
	eigen? ( !atlas !mkl !openblas )
	mkl? ( !atlas !eigen !openblas )
	openblas? ( !atlas !eigen !mkl )
	rocm? ( !mkldnn !cuda )
"

DEPEND="
	dev-libs/protobuf
	dev-python/pyyaml[${PYTHON_USEDEP}]
	>=dev-python/pybind11-2.6.2[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	atlas? ( sci-libs/atlas )
	cuda? ( dev-util/nvidia-cuda-toolkit:0=[profiler] )
	doc? ( dev-python/pytorch-sphinx-theme[${PYTHON_USEDEP}] )
	ffmpeg? ( virtual/ffmpeg )
	gflags? ( dev-cpp/gflags )
	glog? ( dev-cpp/glog )
	leveldb? ( dev-libs/leveldb )
	lmdb? ( dev-db/lmdb )
	mkl? ( sci-libs/mkl )
	mpi? ( virtual/mpi )
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
	openblas? ( sci-libs/openblas )
	opencl? ( dev-libs/clhpp virtual/opencl )
	opencv? ( media-libs/opencv[${PYTHON_USEDEP}] )
	python? ( ${PYTHON_DEPS} )
	redis? ( dev-db/redis )
	rocm? (
		dev-util/amd-rocm-meta
		dev-util/rocm-cmake
		dev-libs/rccl
		sci-libs/miopen
		dev-libs/roct-thunk-interface
	)
	zeromq? ( net-libs/zeromq )
"

RDEPEND="${DEPEND}
	sci-libs/onnx[python?]
"

BDEPEND="
	doc? ( app-doc/doxygen )
"

PATCHES=(
	"${FILESDIR}/1.10/Use-FHS-compliant-paths-from-GNUInstallDirs-module.patch"
	"${FILESDIR}/1.7/Don-t-build-libtorch-again-for-PyTorch.patch"
	"${FILESDIR}/1.7/torch_shm_manager.patch"
	"${FILESDIR}/1.9/Change-path-to-caffe2-build-dir-made-by-libtorch.patch"
	"${FILESDIR}/0004-Don-t-fill-rpath-of-Caffe2-library-for-system-wide-i.patch"
	"${FILESDIR}/1.8/Change-torch_path-part-for-cpp-extensions.patch"
	"${FILESDIR}/0007-Add-necessary-include-directory-for-ATen-CPU-tests.patch"
	"${FILESDIR}/1.9/Fix-ROCm-paths-in-LoadHIP.cmake.patch"
	"${FILESDIR}/Include-neon2sse-third-party-header-library.patch"
	"${FILESDIR}/1.10/Use-system-wide-pybind11-properly.patch"
	"${FILESDIR}/Include-mkl-Caffe2-targets-only-when-enabled.patch"
	"${FILESDIR}/1.8/Use-platform-dependent-LIBDIR-in-TorchConfig.cmake.in.patch"
	"${FILESDIR}/Fix-path-to-torch_global_deps-library-in-installatio.patch"
	"${FILESDIR}/1.9/Don-t-check-submodules-sanity.patch"
	"${FILESDIR}/1.8/cuda-11.4.patch"
	"${FILESDIR}/1.10/fix_c10.patch"
	"${FILESDIR}/1.10/cuda-11.5-cub-namespace.patch"
)

src_prepare() {
	cmake_src_prepare

	eprefixify torch/__init__.py
	echo `pwd`
	rmdir third_party/benchmark || die
	ln -sv "${WORKDIR}"/benchmark-e991355c02b93fe17713efe04cbc2e278e00fdbd third_party/benchmark || die
	rmdir third_party/cpuinfo || die
	ln -sv "${WORKDIR}"/cpuinfo-5916273f79a21551890fd3d56fc5375a78d1598d third_party/cpuinfo || die
	rmdir third_party/cub || die
	ln -sv "${WORKDIR}"/cub-d106ddb991a56c3df1b6d51b2409e36ba8181ce4 third_party/cub || die
	rmdir third_party/fbgemm || die
	ln -sv "${WORKDIR}"/FBGEMM-7588d9d804826b428fc0e4fd418e9cc3f7a72e52 third_party/fbgemm || die
	rmdir third_party/fbgemm/third_party/asmjit || die
	ln -sv "${WORKDIR}"/asmjit-d0d14ac774977d0060a351f66e35cb57ba0bf59c third_party/fbgemm/third_party/asmjit || die
	rmdir third_party/fbgemm/third_party/cpuinfo || die
	ln -sv "${WORKDIR}"/cpuinfo-d5e37adf1406cf899d7d9ec1d317c47506ccb970 third_party/fbgemm/third_party/cpuinfo || die
	rmdir third_party/fbgemm/third_party/googletest || die
	ln -sv "${WORKDIR}"/googletest-0fc5466dbb9e623029b1ada539717d10bd45e99e third_party/fbgemm/third_party/googletest || die
	rmdir third_party/fmt || die
	ln -sv "${WORKDIR}"/fmt-cd4af11efc9c622896a3e4cb599fa28668ca3d05 third_party/fmt || die
	rmdir third_party/foxi || die
	ln -sv "${WORKDIR}"/foxi-c278588e34e535f0bb8f00df3880d26928038cad third_party/foxi || die
	rmdir third_party/FP16 || die
	ln -sv "${WORKDIR}"/FP16-4dfe081cf6bcd15db339cf2680b9281b8451eeb3 third_party/FP16 || die
	rmdir third_party/FXdiv
	ln -sv "${WORKDIR}"/FXdiv-b408327ac2a15ec3e43352421954f5b1967701d1 third_party/FXdiv || die
	rmdir third_party/gemmlowp/gemmlowp || die
	ln -sv "${WORKDIR}"/gemmlowp-3fb5c176c17c765a3492cd2f0321b0dab712f350 third_party/gemmlowp/gemmlowp || die
	rmdir third_party/gloo || die
	ln -sv "${WORKDIR}"/gloo-c22a5cfba94edf8ea4f53a174d38aa0c629d070f third_party/gloo || die
	rmdir third_party/googletest || die
	ln -sv "${WORKDIR}"/googletest-e2239ee6043f73722e7aa812a459f54a28552929 third_party/googletest || die
	rmdir third_party/ideep || die
	ln -sv "${WORKDIR}"/ideep-9ca27bbfd88fa1469cbf0467bd6f14cd1738fa40 third_party/ideep || die
	rmdir third_party/ideep/mkl-dnn || die
	ln -sv "${WORKDIR}"/oneDNN-5ef631a030a6f73131c77892041042805a06064f third_party/ideep/mkl-dnn || die
	rmdir third_party/nccl/nccl || die
	ln -sv "${WORKDIR}"/nccl-033d799524fb97629af5ac2f609de367472b2696 third_party/nccl/nccl || die
	rmdir third_party/NNPACK || die
	ln -sv "${WORKDIR}"/NNPACK-c07e3a0400713d546e0dea2d5466dd22ea389c73 third_party/NNPACK || die
	rmdir third_party/onnx || die
	ln -sv "${WORKDIR}"/onnx-29e7aa7048809784465d06e897f043a4600642b2 third_party/onnx || die
	rmdir third_party/onnx-tensorrt || die
	ln -sv "${WORKDIR}"/onnx-tensorrt-c153211418a7c57ce071d9ce2a41f8d1c85a878f third_party/onnx-tensorrt || die
	rmdir third_party/onnx-tensorrt/third_party/onnx || die
	ln -sv "${WORKDIR}"/onnx-765f5ee823a67a866f4bd28a9860e81f3c811ce8 third_party/onnx-tensorrt/third_party/onnx || die
	rmdir third_party/onnx/third_party/benchmark || die
	ln -sv "${WORKDIR}"/benchmark-e776aa0275e293707b6a0901e0e8d8a8a3679508 third_party/onnx/third_party/benchmark || die
	rmdir third_party/psimd || die
	ln -sv "${WORKDIR}"/psimd-072586a71b55b7f8c584153d223e95687148a900 third_party/psimd || die
	rmdir third_party/pthreadpool || die
	ln -sv "${WORKDIR}"/pthreadpool-a134dd5d4cee80cce15db81a72e7f929d71dd413 third_party/pthreadpool || die
	rmdir third_party/python-peachpy || die
	ln -sv "${WORKDIR}"/PeachPy-07d8fde8ac45d7705129475c0f94ed8925b93473 third_party/python-peachpy || die
	rmdir third_party/QNNPACK || die
	ln -sv "${WORKDIR}"/QNNPACK-7d2a4e9931a82adc3814275b6219a03e24e36b4c third_party/QNNPACK || die
	rmdir third_party/sleef || die
	ln -sv "${WORKDIR}"/sleef-e0a003ee838b75d11763aa9c3ef17bf71a725bff third_party/sleef || die
	rmdir third_party/tensorpipe || die
	ln -sv "${WORKDIR}"/tensorpipe-d2aa3485e8229c98891dfd604b514a39d45a5c99 third_party/tensorpipe || die
	rmdir third_party/tensorpipe/third_party/googletest || die
	ln -sv "${WORKDIR}"/googletest-2fe3bd994b3189899d93f1d5a881e725e046fdc2 third_party/tensorpipe/third_party/googletest || die
	rmdir third_party/tensorpipe/third_party/libnop || die
	ln -sv "${WORKDIR}"/libnop-aa95422ea8c409e3f078d2ee7708a5f59a8b9fa2 third_party/tensorpipe/third_party/libnop || die
	rmdir third_party/tensorpipe/third_party/libuv || die
	ln -sv "${WORKDIR}"/libuv-48e04275332f5753427d21a52f17ec6206451f2c third_party/tensorpipe/third_party/libuv || die
	rmdir third_party/XNNPACK || die
	ln -sv "${WORKDIR}"/XNNPACK-79cd5f9e18ad0925ac9a050b00ea5a36230072db third_party/XNNPACK || die
	rmdir third_party/kineto || die
	ln -sv "${WORKDIR}"/kineto-879a203d9bf554e95541679ddad6e0326f272dc1 third_party/kineto || die
	rmdir third_party/breakpad || die
	ln -sv "${WORKDIR}"/breakpad-edbb99f95c75be27d038fffb1d969cdacf705db2 third_party/breakpad || die
	rmdir third_party/breakpad/src/third_party/lss || die
	ln -sv "${WORKDIR}"/linux-syscall-support-e1e7b0ad8ee99a875b272c8e33e308472e897660 third_party/breakpad/src/third_party/lss || die

	cd third_party/ideep/mkl-dnn
	eapply -p4 "${FILESDIR}/1.10/mkl-dnn-thread-include.patch"
	cd "${S}"

	if use cuda; then
		cd third_party/nccl/nccl || die
		eapply "${FILESDIR}"/${PN}-1.6.0-nccl-nvccflags.patch
		cuda_src_prepare
		export CUDAHOSTCXX=g++-10.3.0
	fi

	if use rocm; then
		#Allow escaping sandbox
		addread /dev/kfd
		addread /dev/dri
		addpredict /dev/kfd
		addpredict /dev/dri

		ebegin "HIPifying cuda sources"
		${EPYTHON} tools/amd_build/build_amd.py || die
		eapply "${FILESDIR}"/${PN}-1.9.1-fix-wrong-hipify.patch
		eend $?

		local ROCM_VERSION="$(hipconfig -v)-"
		export PYTORCH_ROCM_ARCH="${AMDGPU_TARGETS}"
		sed -e "/set(roctracer_INCLUDE_DIRS/s,\${ROCTRACER_PATH}/include,${EPREFIX}/usr/include/roctracer," \
			-e "/PYTORCH_HIP_HCC_LIBRARIES/s,\${HIP_PATH}/lib,${EPREFIX}/usr/lib/hip/lib," \
			-e "s,\${ROCTRACER_PATH}/lib,${EPREFIX}/usr/lib64/roctracer," \
			-e "/READ.*\.info\/version-dev/c\  set(ROCM_VERSION_DEV_RAW ${ROCM_VERSION})" \
			-i cmake/public/LoadHIP.cmake || die
		sed -r -e '/^if\(USE_ROCM/{:a;N;/\nendif/!ba; s,\{([^\{]*)_PATH\}(/include)?,\{\L\1_\UINCLUDE_DIRS\},g}' -i cmake/Dependencies.cmake || die
	fi
}

src_configure() {
	local blas="Eigen"

	if use atlas; then
		blas="ATLAS"
	elif use mkl; then
		blas="MKL"
	elif use openblas; then
		blas="OpenBLAS"
	fi

	if use rocm; then
		export HCC_PATH="${HCC_HOME}"
		export ROCBLAS_PATH="/usr"
		export ROCFFT_PATH="/usr"
		export HIPSPARSE_PATH="/usr"
		export HIPRAND_PATH="/usr"
		export ROCRAND_PATH="/usr"
		export MIOPEN_PATH="/usr"
		export RCCL_PATH="/usr"
		export ROCPRIM_PATH="/usr"
		export HIPCUB_PATH="/usr"
		export ROCTHRUST_PATH="/usr"
		export ROCTRACER_PATH="/usr"
	fi

	local mycmakeargs=(
		-DWERROR=OFF
		-DBLAS=${blas}
		-DBUILDING_SYSTEM_WIDE=ON # to remove insecure DT_RUNPATH header
		-DBUILD_BINARY=$(usex tools ON OFF)
		-DBUILD_CUSTOM_PROTOBUF=OFF
		-DBUILD_DOCS=$(usex doc ON OFF)
		-DBUILD_PYTHON=$(usex python ON OFF)
		-DBUILD_SHARED_LIBS=$(usex static OFF ON)
		-DBUILD_TEST=$(usex test ON OFF)
		-DCAFFE2_USE_MKL=$(usex mkl ON OFF)
		-DTORCH_BUILD_VERSION=${PV}
		-DTORCH_INSTALL_LIB_DIR=lib64
		-DUSE_ASAN=$(usex asan ON OFF)
		-DUSE_CUDA=$(usex cuda ON OFF)
		-DUSE_FBGEMM=$(usex fbgemm ON OFF)
		-DUSE_FFMPEG=$(usex ffmpeg ON OFF)
		-DUSE_GFLAGS=$(usex gflags ON OFF)
		-DUSE_GLOG=$(usex glog ON OFF)
		-DUSE_GLOO=$(usex gloo ON OFF)
		-DUSE_LEVELDB=$(usex leveldb ON OFF)
		-DUSE_LITE_PROTO=OFF
		-DUSE_LMDB=$(usex lmdb ON OFF)
		-DUSE_MKLDNN=$(usex mkldnn ON OFF)
		-DUSE_MKLDNN_CBLAS=OFF
		-DUSE_MPI=$(usex mpi ON OFF)
		-DUSE_NCCL=$(usex cuda ON OFF)
		-DUSE_NNPACK=$(usex nnpack ON OFF)
		-DUSE_NUMA=$(usex numa ON OFF)
		-DUSE_NUMPY=$(usex numpy ON OFF)
		-DUSE_OBSERVERS=$(usex observers ON OFF)
		-DUSE_OPENCL=$(usex opencl ON OFF)
		-DUSE_OPENCV=$(usex opencv ON OFF)
		-DUSE_OPENMP=$(usex openmp ON OFF)
		-DUSE_PROF=OFF
		-DUSE_QNNPACK=$(usex qnnpack ON OFF)
		-DUSE_REDIS=$(usex redis ON OFF)
		-DUSE_ROCKSDB=OFF
		-DUSE_ROCM=$(usex rocm ON OFF)
		-DUSE_SYSTEM_EIGEN_INSTALL=ON
		-DUSE_SYSTEM_NCCL=OFF
		-DUSE_SYSTEM_PYBIND11=ON
		-DUSE_TBB=OFF
		-DUSE_ZMQ=$(usex zeromq ON OFF)
		-DTP_BUILD_LIBUV=OFF
		-Wno-dev
	)

	if use cuda; then
		cuda_host_compiler="/usr/lib/ccache/bin/g++-10.3.0"
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

	cmake_src_configure

	if use python; then
		PYTORCH_BUILD_VERSION="${PV}" CMAKE_BUILD_DIR="${BUILD_DIR}" distutils-r1_src_configure
	fi
}

src_compile() {
	cmake_src_compile

	if use python; then
		PYTORCH_BUILD_VERSION="${PV}" USE_SYSTEM_LIBS=ON CMAKE_BUILD_DIR=${BUILD_DIR} distutils-r1_src_compile
	fi
}

src_install() {
	cmake_src_install

	local multilib_failing_files=(
		libgloo.a
	)

	for file in ${multilib_failing_files[@]}; do
		mv -f "${D}/usr/lib/$file" "${D}/usr/lib64" || die
	done

	rm -rfv "${ED}/torch" || die
	rm -rfv "${ED}/var" || die
	rm -rfv "${ED}/usr/lib" || die

	rm -rfv "${ED}/usr/include/fp16" || die
	rm -rfv "${ED}/usr/include/fp16.h" || die
	rm -r "${ED}/usr/include/asmjit" || die
	rm -r "${ED}/usr/include/c10d" || die
	rm -r "${ED}/usr/include/fbgemm" || die
	rm -r "${ED}/usr/include/fp16" || die
	rm -r "${ED}/usr/include/gloo" || die

	if use rocm; then
		rm -rfv "${ED}/usr/include/hip" || die
	fi

	rm -fv "${ED}/usr/lib64/libtbb.so" || die
	rm -rfv "${ED}/usr/lib64/cmake" || die

	rm -rfv "${ED}/usr/share/doc/mkldnn" || die
	rm -rfv "${ED}/usr/share/doc/dnnl" || die

	rm -rfv "${ED}/usr/include/uv" || die
	rm -fv "${ED}/usr/include/uv.h" || die
	rm -fv "${ED}/usr/lib64/libuv.so" || die
	rm -fv "${ED}/usr/lib64/libuv.so.1" || die
	rm -fv "${ED}/usr/lib64/libuv.so.1.0.0" || die
	rm -rfv "${ED}/usr/lib64/pkgconfig" || die

	if use python; then
		install_shm_manager() {
			python_get_sitedir
			TORCH_BIN_DIR="${ED}/${PYTHON_SITEDIR}/torch/bin"

			mkdir -pv ${TORCH_BIN_DIR} || die
			cp -v "${ED}/usr/bin/torch_shm_manager" "${TORCH_BIN_DIR}" || die
		}

		install_shm_manager
		rm "${ED}/usr/bin/torch_shm_manager" || die

		remove_tests() {
			find "${ED}" -name "*test*" -exec rm -rfv {} \; || die
		}

		scanelf -r --fix "${BUILD_DIR}/caffe2/python" || die
		PYTORCH_BUILD_VERSION="${PV}" CMAKE_BUILD_DIR=${BUILD_DIR} distutils-r1_src_install

		fix_caffe_convert_utils() {
			python_setup
			python_get_scriptdir
			python_get_sitedir

			ln -rnsvf "${ED}/${PYTHON_SCRIPTDIR}/convert-caffe2-to-onnx" "${ED}/usr/bin/" || die
			ln -rnsvf "${ED}/${PYTHON_SCRIPTDIR}/convert-onnx-to-caffe2" "${ED}/usr/bin/" || die

			# copy absent Protobuf-generated Python binding files
			find "${BUILD_DIR}/caffe2/proto" -name "*_pb2.py" -exec cp -v {} "${ED}/${PYTHON_SITEDIR}/caffe2/proto" \; || die
		}

		fix_caffe_convert_utils

		if use test; then
			remove_tests
		fi

		python_optimize
	fi

	find "${ED}/usr/lib64" -name "*.a" -exec rm -fv {} \; || die

	if use test; then
		rm -rfv "${ED}/usr/test" || die
		rm -fv "${ED}/usr/bin/test_api" || die
		rm -fv "${ED}/usr/bin/test_jit" || die
	fi
}
