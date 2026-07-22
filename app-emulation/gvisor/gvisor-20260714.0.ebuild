# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multiprocessing

DESCRIPTION="Application kernel for containers"
HOMEPAGE="https://gvisor.dev/ https://github.com/google/gvisor"
SRC_URI="https://github.com/google/gvisor/archive/refs/tags/release-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/gvisor-release-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"

BDEPEND="
	>=dev-build/bazelisk-1.29
	>=dev-lang/go-1.26
	>=dev-libs/protobuf-34.2
	sys-devel/binutils
	llvm-core/clang
	sys-devel/gcc
"

gvisor_bazel() {
	# Harmless for a real Bazel binary; required when /usr/bin/bazel is Bazelisk.
	# It keeps Bazel's own executable download in WORKDIR, where src_unpack
	# populates it and src_compile can reuse it without a network connection.
	export BAZELISK_HOME="${WORKDIR}/bazelisk"
	"${BROOT}"/usr/bin/bazel \
		--batch \
		--output_user_root="${WORKDIR}/bazel-output-root" \
		"$@"
}

src_unpack() {
	# The patch changes MODULE.bazel, so apply it before `bazel fetch`: the
	# repository cache must contain the system-Go/module configuration that
	# src_compile will use with --nofetch.
	default
	cd "${S}" || die
	eapply \
		"${FILESDIR}/${P}-gentoo-build.patch" \
		"${FILESDIR}/${P}-module-lock.patch"

	# Bazel probes its Linux sandbox through /proc even for `bazel fetch`.
	# Portage's sandbox otherwise rejects that probe before dependency fetch ends.
	addpredict /proc

	# This is the only phase in which Bazel may contact upstream repositories.
	# src_compile uses --nofetch and the same repository cache.
	cd "${S}" || die
	gvisor_bazel fetch \
		--config=x86_64 \
		--repository_cache="${WORKDIR}/bazel-repository-cache" \
		//runsc:runsc || die
}

src_prepare() {
	default
}

src_compile() {
	local bpf_clang
	for bpf_clang in /usr/lib/llvm/*/bin/clang; do
		[[ -x ${bpf_clang} ]] && break
	done
	[[ -x ${bpf_clang} ]] || die "llvm-core/clang did not install a usable clang"
	export GVISOR_BPF_CLANG="${GVISOR_BPF_CLANG:-${bpf_clang}}"

	addpredict /proc

	gvisor_bazel build \
		--action_env=GVISOR_BPF_CLANG \
		--config=x86_64 \
		--jobs="$(makeopts_jobs)" \
		--nofetch \
		--repository_cache="${WORKDIR}/bazel-repository-cache" \
		//runsc:runsc || die
}

src_install() {
	dobin bazel-bin/runsc/runsc_/runsc
}
