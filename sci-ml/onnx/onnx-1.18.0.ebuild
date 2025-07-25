# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{10..13} )
inherit distutils-r1 cmake

DESCRIPTION="Open Neural Network Exchange (ONNX)"
HOMEPAGE="https://github.com/onnx/onnx"
SRC_URI="https://github.com/onnx/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"
IUSE="disableStaticReg"
RESTRICT="test"

RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-libs/protobuf:=[protoc(+)]
	dev-python/protobuf[${PYTHON_USEDEP}]
	dev-python/pybind11[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-1.15.0-hidden.patch

	sed -e "s/\"backend\"/\"setuptools.build_meta\"/g" -i pyproject.toml || die

	sed -E "s/(CMAKE_BUILD_DIR =).*/\1 os.path.realpath\(os.environ['BUILD_DIR']\)/g" -i setup.py || die

	cmake_src_prepare
	distutils-r1_src_prepare
}

python_configure_all()
{
	mycmakeargs=(
		-DONNX_USE_PROTOBUF_SHARED_LIBS=ON
		-DONNX_USE_LITE_PROTO=ON
		-DBUILD_SHARED_LIBS=ON
		-DONNX_DISABLE_STATIC_REGISTRATION=$(usex disableStaticReg ON OFF)
	)
	cmake_src_configure
}

src_configure() {
	distutils-r1_src_configure
}

src_compile() {
	mycmakeargs=(
		-DONNX_USE_PROTOBUF_SHARED_LIBS=ON
		-DONNX_USE_LITE_PROTO=ON
		-DBUILD_SHARED_LIBS=ON
		-DONNX_DISABLE_STATIC_REGISTRATION=$(usex disableStaticReg ON OFF)
	)
	CMAKE_ARGS="${mycmakeargs[@]}" distutils-r1_src_compile
}

python_compile_all() {
	cmake_src_compile
}

python_install_all() {
	cmake_src_install
	distutils-r1_python_install_all
}

src_install() {
	distutils-r1_src_install
}
