# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++17/ggml inference port of NVIDIA NeMo Parakeet ASR, with streaming and a flat C-API"
HOMEPAGE="https://github.com/mudler/parakeet.cpp"

# Upstream tag tarball; GitHub archives unpack to parakeet.cpp-${PV}.
SRC_URI="https://github.com/mudler/parakeet.cpp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Submodule pins of v0.6.1, fetched as tarballs (git archives do not carry
# submodules). ggml only when we build it vendored; ced.cpp / voice-detect.cpp
# only under their USE flags.
GGML_SHA="417a024b4fb6bc3116d41af7c067166a039bdf12"   # ggml v1.0.0
CED_SHA="736a4ee46a31d4ff38b41add65ce0f2cf1aaa05f"
VD_SHA="bca46bcbc2fe68169c2d7c414e9b290a7cb89911"
SRC_URI+="
	!system-ggml? ( https://github.com/ggml-org/ggml/archive/refs/tags/v1.0.0.tar.gz -> ${P}-ggml-1.0.0.tar.gz )
	ced?         ( https://github.com/localai-org/ced.cpp/archive/${CED_SHA}.tar.gz -> ${P}-ced.cpp-${CED_SHA}.tar.gz )
	voicedetect? ( https://github.com/localai-org/voice-detect.cpp/archive/${VD_SHA}.tar.gz -> ${P}-voice-detect.cpp-${VD_SHA}.tar.gz )
"

S="${WORKDIR}/parakeet.cpp-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+ced examples +voicedetect system-ggml vulkan"
RESTRICT="test"

PATCHES=(
	"${FILESDIR}/${P}-ggml100-dl-mel.patch"
	"${FILESDIR}/${P}-build-examples-option.patch"
)

DEPEND="
	system-ggml? ( >=sci-ml/ggml-1.0.0 )
"
RDEPEND="
	system-ggml? ( >=sci-ml/ggml-1.0.0 )
	vulkan? ( media-libs/vulkan-loader )
"
BDEPEND="
	!system-ggml? (
		vulkan? (
			dev-util/spirv-headers
			dev-util/vulkan-headers
			media-libs/shaderc
		)
	)
"

src_unpack() {
	default

	if ! use system-ggml; then
		rm -rf "${S}"/third_party/ggml || die
		mv "${WORKDIR}"/ggml-1.0.0 "${S}"/third_party/ggml || die
	fi
	if use ced; then
		rm -rf "${S}"/third_party/ced.cpp || die
		mv "${WORKDIR}"/ced.cpp-"${CED_SHA}" "${S}"/third_party/ced.cpp || die
	fi
	if use voicedetect; then
		rm -rf "${S}"/third_party/voice-detect.cpp || die
		mv "${WORKDIR}"/voice-detect.cpp-"${VD_SHA}" "${S}"/third_party/voice-detect.cpp || die
	fi
}

src_prepare() {
	use ced && eapply "${FILESDIR}/${P}-ced-ggml100-dl.patch"
	use voicedetect && eapply "${FILESDIR}/${P}-voicedetect-ggml100.patch"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DPARAKEET_BUILD_TESTS=OFF
		-DPARAKEET_BUILD_CLI=ON
		-DPARAKEET_BUILD_SERVER=$(usex examples)
		-DPARAKEET_BUILD_EXAMPLES=$(usex examples)
		-DPARAKEET_SHARED=ON
		-DPARAKEET_WITH_CED=$(usex ced)
		-DPARAKEET_WITH_VOICEDETECT=$(usex voicedetect)
		-DGGML_NATIVE=ON
	)

	if use system-ggml; then
		mycmakeargs+=(
			-DPARAKEET_USE_SYSTEM_GGML=ON
			-DCED_USE_SYSTEM_GGML=ON
			-DVOICEDETECT_USE_SYSTEM_GGML=ON
		)
	else
		mycmakeargs+=( -DPARAKEET_GGML_VULKAN=$(usex vulkan) )
	fi

	cmake_src_configure
}

src_install() {
	# Upstream has no install rules; install the public surface manually.
	dolib.so "${BUILD_DIR}"/libparakeet.so
	dobin "${BUILD_DIR}"/examples/cli/parakeet-cli
	if use examples; then
		dobin "${BUILD_DIR}"/examples/cli/diarize
		use ced && dobin "${BUILD_DIR}"/examples/cli/sound-window-eval
		dobin "${BUILD_DIR}"/examples/server/parakeet-server
	fi

	# Public headers
	doheader include/parakeet.h
	doheader include/parakeet_capi.h

	einstalldocs
}

pkg_postinst() {
	elog "GGUF models are not packaged: convert NeMo checkpoints with the"
	elog "upstream scripts, or download them from HuggingFace"
	elog "(mudler/parakeet.cpp-110m and the realtime_eou variants)."
}
