# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

DISTUTILS_OPTIONAL=1

inherit distutils-r1 cmake-utils git-r3 python-r1 python-utils-r1 cuda

DESCRIPTION="An open source machine learning framework"
HOMEPAGE="https://pytorch.org/"

EGIT_REPO_URI="https://github.com/${PN}/${PN}"
EGIT_SUBMODULES=(
	'*'
	'-third_party/protobuf'
	'-third_party/ios-cmake'
	'-third_party/gflags'
	'-third_party/glog'
	'-third_party/pybind11'
)

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS=""
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
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/pybind11[${PYTHON_USEDEP}]
	>=dev-libs/libuv-1.26.0[static-libs]
	atlas? ( sci-libs/atlas )
	cuda? ( dev-util/nvidia-cuda-toolkit:0= )
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
RDEPEND="${DEPEND}"
BDEPEND="
	doc? ( app-doc/doxygen )
"

PATCHES=(
	"${FILESDIR}/0001-Fix-install-dirs.patch"
	"${FILESDIR}/0003-Change-path-to-caffe2-build-dir-made-by-libtorch.patch"
	"${FILESDIR}/0004-Don-t-fill-rpath-of-Caffe2-library-for-system-wide-i.patch"
	"${FILESDIR}/0005-Change-library-directory-according-to-CMake-build.patch"
	"${FILESDIR}/0006-Change-torch_path-part-for-cpp-extensions.patch"
	"${FILESDIR}/0007-Add-necessary-include-directory-for-ATen-CPU-tests.patch"
	"${FILESDIR}/0002-Fix-rocThrust-include-dirs.patch"
	"${FILESDIR}/0003-Fix-some-ROCm-library-paths.patch"
	"${FILESDIR}/0004-Fix-roctracer-include-path.patch"
	"${FILESDIR}/Use-system-wide-pybind11-properly.patch"
	"${FILESDIR}/0006-Use-platform-dependt-libdir-in-TorchConfig.cmake.in.patch"
	"${FILESDIR}/Include-neon2sse-third-party-header-library.patch"
	"${FILESDIR}/Include-mkl-Caffe2-targets-only-when-enabled.patch"
	"${FILESDIR}/Fix-path-to-torch_global_deps-library-in-installatio.patch"
	"${FILESDIR}/fbgemm-gcc10.patch"
	"${FILESDIR}/0003-Fix-wheel-build.patch"
	"${FILESDIR}/0002-Don-t-build-caffe2-again.patch"
	"${FILESDIR}/0001-Don-t-build-libuv.patch"
)

src_prepare() {
	cmake-utils_src_prepare

	if use rocm; then
		${EPYTHON} "${S}/tools/amd_build/build_amd.py"
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
		-DTORCH_BUILD_VERSION=$(cat ${S}/version.txt)+$(git -C ${S} rev-parse HEAD | cut -c -7)
		-DTORCH_INSTALL_LIB_DIR=lib64
		-DBUILD_BINARY=$(usex tools ON OFF)
		-DBUILD_CUSTOM_PROTOBUF=OFF
		-DBUILD_DOCS=$(usex doc ON OFF)
		-DBUILD_PYTHON=$(usex python ON OFF)
		-DBUILD_SHARED_LIBS=$(usex static OFF ON)
		-DBUILD_TEST=$(usex test ON OFF)
		-DUSE_ASAN=$(usex asan ON OFF)
		-DUSE_CUDA=$(usex cuda ON OFF)
		-DUSE_ROCM=$(usex rocm ON OFF)
		-DUSE_FBGEMM=$(usex fbgemm ON OFF)
		-DUSE_FFMPEG=$(usex ffmpeg ON OFF)
		-DUSE_GFLAGS=$(usex gflags ON OFF)
		-DUSE_GLOG=$(usex glog ON OFF)
		-DUSE_LEVELDB=$(usex leveldb ON OFF)
		-DUSE_LITE_PROTO=OFF
		-DUSE_LMDB=$(usex lmdb ON OFF)
		-DCAFFE2_USE_MKL=$(usex mkl ON OFF)
		-DUSE_MKLDNN=$(usex mkldnn ON OFF)
		-DUSE_MKLDNN_CBLAS=OFF
		-DUSE_NCCL=OFF
		-DUSE_NNPACK=$(usex nnpack ON OFF)
		-DUSE_NUMPY=$(usex numpy ON OFF)
		-DUSE_NUMA=$(usex numa ON OFF)
		-DUSE_OBSERVERS=$(usex observers ON OFF)
		-DUSE_OPENCL=$(usex opencl ON OFF)
		-DUSE_OPENCV=$(usex opencv ON OFF)
		-DUSE_OPENMP=$(usex openmp ON OFF)
		-DUSE_TBB=OFF
		-DUSE_PROF=OFF
		-DUSE_QNNPACK=$(usex qnnpack ON OFF)
		-DUSE_REDIS=$(usex redis ON OFF)
		-DUSE_ROCKSDB=OFF
		-DUSE_ZMQ=$(usex zeromq ON OFF)
		-DUSE_MPI=$(usex mpi ON OFF)
		-DUSE_GLOO=$(usex gloo ON OFF)
		-DBLAS=${blas}
		-DBUILDING_SYSTEM_WIDE=ON # to remove insecure DT_RUNPATH header
	)

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
		distutils-r1_src_configure
	fi
}

src_compile() {
	cmake-utils_src_compile

	if use python; then
		CMAKE_BUILD_DIR=${BUILD_DIR} distutils-r1_src_compile
	fi
}

src_install() {
	cmake-utils_src_install

	local multilib_failing_files=(
		libgloo.a
		libsleef.a
	)

	for file in ${multilib_failing_files[@]}; do
		mv -f "${D}/usr/lib/$file" "${D}/usr/lib64" || die
	done

	rm -rfv "${D}/torch" || die
	rm -rfv "${D}/var" || die
	rm -rfv "${D}/usr/lib" || die

	rm -rfv "${D}/usr/include/fp16" || die
	rm -rfv "${D}/usr/include/fp16.h" || die

	if use rocm; then
		rm -rfv "${D}/usr/include/hip" || die
	fi

	rm -fv "${D}/usr/lib64/libtbb.so" || die
	rm -rfv "${D}/usr/lib64/cmake" || die

	rm -rfv "${D}/usr/share/doc/mkldnn" || die

	if use python; then
		install_shm_manager() {
			python_get_sitedir
			TORCH_BIN_DIR="${D}/${PYTHON_SITEDIR}/torch/bin"

			mkdir -pv ${TORCH_BIN_DIR} || die
			cp -v "${D}/usr/bin/torch_shm_manager" "${TORCH_BIN_DIR}" || die
		}

		python_foreach_impl install_shm_manager
		rm "${D}/usr/bin/torch_shm_manager" || die

		remove_tests() {
			find "${D}" -name "*test*" -exec rm -rfv {} \; || die
		}

		scanelf -r --fix "${BUILD_DIR}/caffe2/python" || die
		CMAKE_BUILD_DIR=${BUILD_DIR} distutils-r1_src_install

		fix_caffe_convert_utils() {
			python_setup
			python_get_scriptdir
			python_get_sitedir

			ln -rnsvf "${D}/${PYTHON_SCRIPTDIR}/convert-caffe2-to-onnx" "${D}/usr/bin/" || die
			ln -rnsvf "${D}/${PYTHON_SCRIPTDIR}/convert-onnx-to-caffe2" "${D}/usr/bin/" || die

			# copy absent Protobuf-generated Python binding files
			find "${BUILD_DIR}/caffe2/proto" -name "*_pb2.py" -exec cp -v {} "${D}/${PYTHON_SITEDIR}/caffe2/proto" \; || die
		}

		fix_caffe_convert_utils

		if use test; then
			python_foreach_impl remove_tests
		fi

		python_foreach_impl python_optimize
	fi

	find "${D}/usr/lib64" -name "*.a" -exec rm -fv {} \; || die

	if use test; then
		rm -rfv "${D}/usr/test" || die
		rm -fv "${D}/usr/bin/test_api" || die
		rm -fv "${D}/usr/bin/test_jit" || die
	fi
}
