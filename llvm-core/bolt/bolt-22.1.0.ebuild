# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit cmake flag-o-matic llvm.org llvm-utils python-any-r1 toolchain-funcs

DESCRIPTION="LLVM BOLT"
HOMEPAGE="https://llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="${LLVM_MAJOR}/${LLVM_SOABI}"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86 ~arm64-macos"
IUSE="debug test"
RESTRICT="!test? ( test )"

DEPEND="
	~llvm-core/llvm-${PV}[debug=]
	sys-libs/zlib:=
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	llvm-core/llvm:${LLVM_MAJOR}
	test? (
		$(python_gen_any_dep ">=dev-python/lit-${PV}[\${PYTHON_USEDEP}]")
	)
"

LLVM_COMPONENTS=( llvm cmake bolt third-party )
LLVM_USE_TARGETS=provide
llvm.org_set_globals

python_check_deps() {
	python_has_version ">=dev-python/lit-${PV}[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_unpack() {
	llvm.org_src_unpack

	# Directory ${WORKDIR}/llvm does not exist with USE="-test",
	# but LLVM_MAIN_SRC_DIR="${WORKDIR}/llvm" is set below,
	# and ${LLVM_MAIN_SRC_DIR}/../libunwind/include is used by build system
	# (lld/MachO/CMakeLists.txt) and is expected to be resolvable
	# to existent directory ${WORKDIR}/libunwind/include.
	mkdir -p "${WORKDIR}/llvm" || die
}

src_configure() {
	llvm_prepend_path "${LLVM_MAJOR}"

	# ODR violations (https://github.com/llvm/llvm-project/issues/83529, bug #922353)
	filter-lto

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"

	use elibc_musl && append-ldflags -Wl,-z,stack-size=2097152

	local mycmakeargs=(
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${LLVM_MAJOR}"
		-DBUILD_SHARED_LIBS=OFF

		# cheap hack: LLVM combines both anyway, and the only difference
		# is that the former list is explicitly verified at cmake time
		-DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"
		-DLLVM_BUILD_TESTS=$(usex test)
		-DLLVM_INCLUDE_TESTS=$(usex test)

		# disable various irrelevant deps and settings
		-DLLVM_ENABLE_FFI=OFF
		-DLLVM_ENABLE_TERMINFO=OFF
		-DHAVE_HISTEDIT_H=NO
		-DLLVM_ENABLE_ASSERTIONS=$(usex debug)
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON

		-DLLVM_HOST_TRIPLE="${CHOST}"

		-DLLVM_ENABLE_PROJECTS="bolt"
		-DBOLT_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"
		-DBOLT_ENABLE_RUNTIME=ON
		-DLLVM_INCLUDE_BENCHMARKS=OFF

		-DPython3_EXECUTABLE="${PYTHON}"
	)

	use test && mycmakeargs+=(
		-DLLVM_EXTERNAL_LIT="${EPREFIX}/usr/bin/lit"
		-DLLVM_LIT_ARGS="$(get_lit_flags)"
	)

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	# also: custom rules for OCaml do not work for CPPFLAGS
	use debug || local -x CFLAGS="${CFLAGS} -DNDEBUG"
	cmake_src_configure
}

src_compile() {
	cmake_build bolt
}

src_test() {
	local -x LIT_PRESERVES_TMP=1
	cmake_build check-bolt
}

src_install() {
	DESTDIR="${D}" \
	cmake -P "${BUILD_DIR}"/tools/bolt/cmake_install.cmake || die
}
