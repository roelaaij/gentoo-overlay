# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Vector search SQLite extension based on faiss!"
HOMEPAGE="https://github.com/asg017/${PN}"
SRC_URI="https://github.com/asg017/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

inherit cmake

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-db/sqlite:=
	sci-libs/faiss
	dev-cpp/nlohmann_json
"
DEPEND="${RDEPEND}"

PATCHES=(
	${FILESDIR}/${PN}-cmake-system-libs.patch
	${FILESDIR}/${PN}-faiss-include.patch
)

src_configure() {
	export SQLITE_VSS_CMAKE_VERSION=$(sed 's/-alpha//g' ${S}/VERSION)
	einfo "Version ${SQLITE_VSS_CMAKE_VERSION}"
	mycmakeargs=(
		-DUSE_SYSTEM_JSON=ON
		-DUSE_SYSTEM_FAISS=ON
		-DUSE_SYSTEM_SQLITE=ON
		-DBUILD_STATIC=OFF
		-DBUILD_SHARED=ON
	)
	cmake_src_configure
}

src_install() {
	dolib.so ${BUILD_DIR}/vector0.so
	dolib.so ${BUILD_DIR}/vss0.so
}
