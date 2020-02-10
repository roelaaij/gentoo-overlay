# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit toolchain-funcs python-any-r1 cmake-utils

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="https://ispc.github.com/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
IUSE="examples -debug"

RDEPEND="
	>=sys-devel/clang-3.0:*[debug?]
	>=sys-devel/llvm-3.0:*[debug?]
	"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	sys-devel/bison
	sys-devel/flex
	"

PATCHES=( "${FILESDIR}/${PN}-no-timestamp.patch"
		  "${FILESDIR}/${PN}-no-build-type-check.patch" )

src_prepare() {
	sed -e 's/-Werror//' -i CMakeLists.txt || die
	cmake-utils_src_prepare
}

src_configure() {
	# Disable building the examples and install their source manually later
	local mycmakeargs=(
		-DARM_ENABLED=OFF
		-DISPC_INCLUDE_EXAMPLES=OFF
		-DISPC_NO_DUMPS=$(usex debug OFF ON)
	)
	cmake-utils_src_configure
}

# src_compile() {
# 	#make all slient commands ("@") verbose and remove -Werror (ispc/ispc#1295)
# 	# emake LDFLAGS="${LDFLAGS}" OPT="${CXXFLAGS}" CXX="$(tc-getCXX)" CPP="$(tc-getCPP)"
# 	cmake_utils
# }

src_install() {
	cmake-utils_src_install

	if use examples; then
		insinto "/usr/share/doc/${PF}/examples"
		docompress -x "/usr/share/doc/${PF}/examples"
		doins -r examples/*
	fi
}
