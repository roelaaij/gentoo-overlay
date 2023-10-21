# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit python-any-r1 cmake

COMMIT_HASH="49e854d805d916b2031e337763928d2f8d2e1fbf"
DESCRIPTION="part of the PyTorch Profiler"
HOMEPAGE="https://github.com/pytorch/kineto"
SRC_URI="https://github.com/pytorch/${PN}/archive/${COMMIT_HASH}.zip
	-> ${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test cuda"

RDEPEND="
	dev-libs/libfmt
"
DEPEND="${RDEPEND}"
BDEPEND="
	test? ( dev-cpp/gtest )
	${PYTHON_DEPS}
"
RESTRICT="!test? ( test )"

S=${WORKDIR}/${PN}-${COMMIT_HASH}

PATCHES=(
	"${FILESDIR}"/${PN}-2023-08-09-gentoo.patch
	"${FILESDIR}"/${PN}-2023-08-09-gcc13.patch
)

src_prepare() {
	cd libkineto
	if use cuda; then
		mycmakeargs=(
			-DCUDA_SOURCE_DIR=/opt/cuda
			-DLIBKINETO_NOCUPTI=OFF
		)
	fi

	cmake_src_prepare
}

src_configure() {
	cd libkineto
	cmake_src_configure
}
