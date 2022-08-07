# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake vcs-snapshot

DESCRIPTION="An ARM dynamic recompiler"
HOMEPAGE="https://github.com/MerryMage/dynarmic"
SRC_URI="https://github.com/MerryMage/${PN}/archive/r${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/merryhime/mp/archive/refs/tags/v1.0.tar.gz -> ${PN}-mp-1.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="dev-libs/boost:="
DEPEND="${RDEPEND}
	dev-cpp/catch:0
	dev-cpp/robin-map
	dev-libs/libfmt:=
	dev-libs/xbyak
"

PATCHES=(
	"${FILESDIR}/dynarmic-skip-bundled-dependencies.patch"
)

src_unpack() {
	unpack ${P}.tar.gz
	cd ${WORKDIR}/externals
	unpack ${PN}-mp-1.0.tar.gz
	mv mp-1.0 mp || die
	cd ${WORKDIR}
}

src_prepare() {
	cmake_src_prepare
	rm -r externals/{catch,fmt,xbyak} || die
}

src_configure() {
	local mycmakeargs=(
		-DDYNARMIC_SKIP_EXTERNALS=ON
		-DDYNARMIC_TESTS=$(usex test)
		-DDYNARMIC_WARNINGS_AS_ERRORS=OFF
	)
	cmake_src_configure
}

src_install() {
	insinto /usr/include
	doins -r "include/${PN}"

	dolib.so "${BUILD_DIR}/src/lib${PN}.so"
}
