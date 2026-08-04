# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake edo flag-o-matic python-r1

EIGEN_COMMIT="1d8b82b0740839c0de7f1242a3585e3390ff5f33"
ONNX_V="1.22.0"
DESCRIPTION="Cross-platform, high performance ML inferencing and training accelerator"
HOMEPAGE="
	https://onnxruntime.ai
	https://github.com/microsoft/onnxruntime
"
SRC_URI="
	https://github.com/microsoft/onnxruntime/archive/refs/tags/v${PV}.zip -> ${P}.zip
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN_COMMIT}/eigen-${EIGEN_COMMIT}.tar.bz2 ->
		eigen-3.4.0_p20250216.tar.bz2
	https://github.com/onnx/onnx/archive/refs/tags/v${ONNX_V}.tar.gz -> onnx-${ONNX_V}.tar.gz
	https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v1.24.0.zip -> cudnn-frontend-1.24.0.zip
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-libs/cpuinfo
	dev-libs/protobuf:=
	dev-libs/re2:=

	python? (
		${PYTHON_DEPS}
		dev-python/coloredlogs[${PYTHON_USEDEP}]
		dev-python/flatbuffers[${PYTHON_USEDEP}]
		>=dev-python/numpy-2[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
		dev-python/sympy[${PYTHON_USEDEP}]
	)
"
DEPEND="
	${RDEPEND}
	dev-cpp/ms-gsl
	dev-cpp/nlohmann_json
	dev-cpp/safeint
	dev-libs/boost
	dev-libs/date
	dev-libs/flatbuffers

	python? (
		dev-python/pybind11[${PYTHON_USEDEP}]
		sci-libs/dlpack
	)
"
BDEPEND="
	${PYTHON_DEPS}

	test? (
		dev-cpp/gtest

		python? ( dev-python/pytest[${PYTHON_USEDEP}] )
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-1.22.2-relax-the-dependency-on-flatbuffers.patch"
	"${FILESDIR}/${PN}-1.24.1-onnx-static-libs.patch"
	"${FILESDIR}/${PN}-1.24.4-no-werror.patch"
	"${FILESDIR}/${PN}-1.26.0-r1-prevent-generation-of-PIE.patch"
	"${FILESDIR}/${PN}-1.28.0-use-system-libraries.patch"
	"${FILESDIR}/${PN}-1.28.0-fix-cuda-build.patch"
)

CMAKE_USE_DIR="${S}/cmake"

src_prepare() {
	cmake_src_prepare
	cd ${WORKDIR}/onnx-${ONNX_V}
	eapply ${CMAKE_USE_DIR}/patches/onnx/onnx.patch
	eapply ${FILESDIR}/onnx-1.21.1-force-static-libs.patch
}

src_configure() {
	# Python is used at build time unconditionally
	python_setup

	local mycmakeargs=(
		-Donnxruntime_BUILD_SHARED_LIB=on

		-Donnxruntime_BUILD_UNIT_TESTS=$(usex test)
		-Donnxruntime_ENABLE_PYTHON=$(usex python)

		# This is required until a newer version of Eigen3 comes out
		-DFETCHCONTENT_SOURCE_DIR_EIGEN3="${WORKDIR}/eigen-${EIGEN_COMMIT}"

		# onnxruntime carries some private patches for onnx
		-DFETCHCONTENT_SOURCE_DIR_ONNX="${WORKDIR}/onnx-${ONNX_V}"

		# onnxruntime carries some private patches for onnx
		-DFETCHCONTENT_SOURCE_DIR_CUDNN_FRONTEND="${WORKDIR}/cudnn-frontend-1.24.0"

		# This makes it possible for `find_path` to find the `onnx-ml.proto` file
		-DCMAKE_INCLUDE_PATH="$(python_get_sitedir)"

		-Wno-dev
	)

	append-ldflags -Wl,-z,noexecstack

	if use python; then
		python_foreach_impl cmake_src_configure
	else
		cmake_src_configure
	fi
}

src_compile() {
	if use python; then
		python_foreach_impl cmake_src_compile
	else
		cmake_src_compile
	fi
}

# Adapted from `run_onnxruntime_tests` in `tools/ci_build/build.py`
python_test() {
	cd "${BUILD_DIR}" || die
	epytest --pyargs \
		onnxruntime_test_python.py \
		onnxruntime_test_python_backend.py \
		onnxruntime_test_python_mlops.py \
		onnxruntime_test_python_sparse_matmul.py
}

src_test() {
	# https://bugs.gentoo.org/975584
	local GTEST_SKIP_TESTS=(
		"ActivationOpNoInfTest.Softsign"
		"ConvTransposeTest.ConvTranspose_InvalidKernelShape"
		"GraphTransformationTests.GatherToSliceFusion"
		"LabelEncoder.RejectsInMemoryExternalDataInKeysTensorOpset4"
		"MLOpTest.TreeEnsembleRegressorRejectsInMemoryExternalDataInTensorAttribute"
		"MLOpTest.TreeEnsembleRejectsInMemoryExternalDataInTensorAttribute"
		"NhwcTransformerTests.ConvFloat_UsesNhwcOnlyWithKleidi"
		"Random.MultinomialDefaultDType"
		"Random.MultinomialGoodCase"
		"SamplingTest.Gpt2Sampling_CPU"
		"SignalOpsTest.DFT17_2D_complex_onesided_inverse"
		"SignalOpsTest.DFT17_IRFFT_naive"
		"SignalOpsTest.DFT17_IRFFT_radix2"
		"SignalOpsTest.DFT17_RFFT_IRFFT_roundtrip"
		"SignalOpsTest.DFT20_2D_complex_onesided_inverse"
		"SignalOpsTest.DFT20_IRFFT_naive"
		"SignalOpsTest.DFT20_IRFFT_radix2"
		"SignalOpsTest.DFT20_RFFT_IRFFT_roundtrip"
	)
	local -x GTEST_FILTER="*:-$(IFS=':'; echo "${GTEST_SKIP_TESTS[*]}")"

	if use python; then
		python_foreach_impl cmake_src_test
		python_foreach_impl python_test
	else
		cmake_src_test
	fi
}

# There is some custom logic in `setup.py`
python_install() {
	cd "${BUILD_DIR}" || die
	edo "${EPYTHON}" ../setup.py install \
		--prefix="${EPREFIX}/usr" \
		--root="${D}"

	rm -rf "${D}/$(python_get_sitedir)"/*.egg-info || die
	python_optimize
}

src_install() {
	if use python; then
		python_foreach_impl cmake_src_install
		python_foreach_impl python_install
	else
		cmake_src_install
	fi

	einstalldocs
}
