# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="XTensor library"
HOMEPAGE="https://github.com/${PN}-stack/${PN}"
SRC_URI="https://github.com/${PN}-stack/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+simd tbb test"

DEPEND=">=dev-cpp/xtl-0.6.11
		simd? ( >=dev-cpp/xsimd-7.4.5 )
		tbb? ( dev-cpp/tbb )
		test? ( dev-cpp/gtest )"
RDEPEND="${DEPEND}"

src_configure() {
	# Disable building the examples and install their source manually later
	local mycmakeargs=(
		-DXTENSOR_USE_XSIMD=$(usex simd)
		-DXTENSOR_USE_TBB=$(usex tbb)
		-DBUILD_TESTS=$(usex test)
		-DDOWNLOAD_GTEST=OFF
		-DBUILD_BENCHMARK=OFF
	)
	cmake-utils_src_configure
}
