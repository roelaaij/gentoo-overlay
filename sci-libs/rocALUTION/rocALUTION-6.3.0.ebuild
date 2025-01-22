
# Copyright
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DIR="docs/.doxygen"
DOCS_DEPEND="media-gfx/graphviz"
ROCM_VERSION=${PV}
inherit cmake docs rocm

DESCRIPTION="Next generation library for iterative sparse solvers for ROCm platform"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocALUTION"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocALUTION/archive/rocm-${PV}.tar.gz -> rocALUTION-${PV}.tar.gz"
S="${WORKDIR}/${PN}-rocm-${PV}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="hip +openmp mpi video_cards_amdgpu"
REQUIRED_USE="|| ( hip openmp mpi )
	 ${ROCM_REQUIRED_USE}"

BDEPEND="
	>=dev-build/rocm-cmake-5.3
"

RDEPEND="hip? ( dev-util/hip )
	 hip? ( sci-libs/rocSPARSE:$SLOT[${ROCM_USEDEP}] )
	 hip? ( sci-libs/rocBLAS:$SLOT[${ROCM_USEDEP}] )
	 mpi? ( virtual/mpi )
"

QA_FLAGS_IGNORED="/usr/lib64/rocalution/library/.*"

pkg_pretend() {
		[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
		[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

PATCHES=(
	"${FILESDIR}"/hipcc-detection.patch
	)

src_prepare() {

	sed -e "s: PREFIX rocalution):):" -i src/CMakeLists.txt
#	sed -e "s:/opt/rocm/hip/cmake:${EPREFIX}/usr/lib/hip/$(ver_cut 1-2)/cmake:" -i "${S}/CMakeLists.txt"
	sed -e "s:/opt/rocm/hip/cmake:${EPREFIX}/usr/lib/hip/cmake:" -i "${S}/CMakeLists.txt"
	sed -e "s:PREFIX rocalution:#PREFIX rocalution:" -i "${S}/src/CMakeLists.txt"
	sed -e "s:rocm_install_symlink_subdir(rocalution):#rocm_install_symlink_subdir(rocalution):" -i "${S}/src/CMakeLists.txt"

	cmake_src_prepare
}

src_configure() {
	rocm_use_hipcc

	export ROCM_PATH="${EPREFIX}/usr"

	local mycmakeargs=(
		-DUSE_HIPCXX=$(usex hip ON OFF)
		-DSUPPORT_OMP=$(usex openmp ON OFF)
		-DSUPPORT_HIP=$(usex hip ON OFF)
		-DSUPPORT_MPI=$(usex mpi ON OFF)
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocALUTION"
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_EXAMPLES=ON
	)

	cmake_src_configure
}

src_compile() {
	docs_compile
	cmake_src_compile
}

src_install() {
	cmake_src_install

	chrpath --delete "${D}/usr/$(get_libdir)/librocalution.so.0.1"
	dostrip -x "/usr/$(get_libdir)/rocalution/library/"
}
