# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit cmake-utils python-any-r1

DESCRIPTION="XTensor Python bindings"
HOMEPAGE="https://github.com/xtensor-stack/${PN}"
SRC_URI="https://github.com/xtensor-stack/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+simd test"

DEPEND="${PYHTON_DEPS}
		>=dev-python/pybind11-2.4.3
		>=dev-python/numpy-1.14.0
		>=dev-cpp/xtensor-0.21.2[simd?]
		test? ( dev-cpp/gtest )"
RDEPEND="${DEPEND}"

src_prepare() {
	cmake-utils_src_prepare
	cp "${FILESDIR}/Findpybind11.cmake" "${S}/cmake"
}

src_configure() {
	# Disable building the examples and install their source manually later
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DDOWNLOAD_GTEST=OFF
	)
	cmake-utils_src_configure
}
