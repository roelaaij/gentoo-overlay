
# Copyright
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DIR="docs/.doxygen"
DOCS_DEPEND="media-gfx/graphviz"
LLVM_COMPAT=( 23 )
ROCM_VERSION=${PV}

inherit cmake docs edob flag-o-matic llvm-r2 rocm

DESCRIPTION="Next generation library for iterative sparse solvers for ROCm platform"
HOMEPAGE="https://github.com/ROCm/rocALUTION"

SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-${PV%.0}/rocalution.tar.gz -> rocalution-${PV}.tar.gz"
S="${WORKDIR}/rocalution"
SLOT="0/$(ver_cut 1-2)"
SLOT_NOLIVE=${SLOT}
KEYWORDS="~amd64"

LICENSE="MIT"

IUSE="hip +openmp mpi"
REQUIRED_USE="|| ( hip openmp mpi )
	 ${ROCM_REQUIRED_USE}"

BDEPEND="
	dev-build/rocm-cmake:${SLOT}
"

RDEPEND="
	hip? ( dev-util/hip:${SLOT} )
	hip? ( sci-libs/rocSPARSE:${SLOT} )
	hip? ( sci-libs/rocBLAS:${SLOT} )
	mpi? ( virtual/mpi )
"

QA_FLAGS_IGNORED="/usr/lib64/rocalution/library/.*"

pkg_pretend() {
		[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
		[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {

	sed -e "s: PREFIX rocalution):):" -i src/CMakeLists.txt
	sed -e "s:PREFIX rocalution:#PREFIX rocalution:" -i "${S}/src/CMakeLists.txt"
	sed -e "s:rocm_install_symlink_subdir(rocalution):#rocm_install_symlink_subdir(rocalution):" -i "${S}/src/CMakeLists.txt"

	cmake_src_prepare
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"
	rocm_use_clang

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DROCM_SYMLINK_LIBS=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DUSE_HIPCXX=$(usex hip ON OFF)
		-DSUPPORT_OMP=$(usex openmp ON OFF)
		-DSUPPORT_HIP=$(usex hip ON OFF)
		-DSUPPORT_MPI=$(usex mpi ON OFF)
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocALUTION"
		-DBUILD_SHARED_LIBS=ON
	)

	cmake_src_configure
}

src_compile() {
	docs_compile
	cmake_src_compile
}

src_install() {
	cmake_src_install

	# Stop llvm-strip from removing .strtab section from *.hsaco files,
	# otherwise rocclr/elf/elf.cpp complains with "failed: null sections(STRTAB)" and crashes
	dostrip -x "/usr/$(get_libdir)/rocalution/library/"
}
