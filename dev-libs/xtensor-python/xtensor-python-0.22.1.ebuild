# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit cmake-utils python-any-r1

DESCRIPTION="XTensor Python bindings"
HOMEPAGE="https://github.com/QuantStack/${PN}"
SRC_URI="https://github.com/QuantStack/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+simd test"

DEPEND="${PYHTON_DEPS}
		>=dev-libs/pybind11-2.1.0
		>=dev-python/numpy-1.14.0
		dev-cpp/xtensor[simd?]
		test? ( dev-cpp/gtest )"
RDEPEND="${DEPEND}"

src_configure() {
	# Disable building the examples and install their source manually later
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DDOWNLOAD_GTEST=OFF
	)
	cmake-utils_src_configure
}
