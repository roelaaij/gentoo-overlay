# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# The v12 series is upstream's Rust rewrite (a Cargo workspace under
# pnpm/crates/*); the release tag also carries prebuilt binaries, which we
# do not use: cargo builds the pnpm-cli crate from source.
#
# Vendored crates tarball (crates.io + git dependencies alike), created with:
#   git clone --depth 1 --branch v${PV} https://github.com/pnpm/pnpm
#   cd pnpm && cargo vendor vendor > vendor-config.txt
#   tar -acf pnpm-${PV}-crates.tar.xz vendor
# cargo vendor checks out git dependencies (e.g. pnpm/node-semver-rs) into
# the vendor tree, so a single tarball covers every source; the matching
# .cargo/config.toml is shipped as files/pnpm-${PV}-vendor_config.

RUST_MIN_VER="1.97.0"

inherit cargo

DESCRIPTION="Fast, disk space efficient package manager (Rust implementation)"
HOMEPAGE="https://pnpm.io/ https://github.com/pnpm/pnpm"
SRC_URI="
	https://github.com/pnpm/pnpm/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${P}-crates.tar.xz
"

S="${WORKDIR}/${P}"

LICENSE="MIT"
# Vendored crates.
LICENSE+=" Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 CC0-1.0
	ISC MIT MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="net-libs/nodejs"

QA_FLAGS_IGNORED="usr/bin/pnpm"
QA_PRESTRIPPED="usr/bin/pnpm"

src_unpack() {
	cargo_src_unpack
	# The crates tarball is rooted at vendor/; unpack it into ${S}.
	cd "${S}" || die
	unpack "${P}-crates.tar.xz"
	mkdir -p .cargo || die
	cp "${FILESDIR}/${P}-vendor_config" .cargo/config.toml || die
}

src_configure() {
	cargo_src_configure
}

src_compile() {
	cargo_src_compile --offline -p pnpm-cli
}

src_install() {
	# cargo install has no -p; install the built binary directly.
	dobin target/release/pnpm
	einstalldocs
	# shell completions
}
