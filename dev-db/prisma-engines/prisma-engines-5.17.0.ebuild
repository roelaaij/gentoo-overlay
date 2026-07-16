# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

RUST_MAX_VER="1.86.0"

inherit systemd cargo linux-info udev xdg desktop

DESCRIPTION="Prisma Engines"
HOMEPAGE="https://github.com/prisma/prisma-engines"

SRC_URI="
	https://github.com/prisma/${PN}/archive/refs/tags/${PV}/${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/-/project/20328305/uploads/0f0ff7247d7a63cae89a4a705c78f4ad/vendor_${PN}_${PV}.tar.xz -> vendor_${PN}_${PV}.tar.xz
"
LICENSE="0BSD"
KEYWORDS="~amd64"
IUSE=""
SLOT="0/5"
RDEPEND=""

PATCHES=(
	"${FILESDIR}"/${P}-time-update.patch
	"${FILESDIR}"/${P}-allow-some-warnings.patch
)

src_unpack() {
	cargo_src_unpack

	mv ${WORKDIR}/vendor ${S} || die
}

src_prepare() {
	# adding vendor package config
	mkdir -p ${S}/.cargo && cp ${FILESDIR}/${P}-vendor_config ${S}/.cargo/config.toml

	default
	rust_pkg_setup
}

src_configure() {
	cargo_src_configure --no-default-features --frozen --bin query-engine --bin schema-engine --bin prisma-fmt
}

src_install() {
	declare -a ECARGO_ARGS=([0]="--frozen" [1]="--no-default-features")
	cargo_src_install --path schema-engine/cli --bin schema-engine
	cargo_src_install --path query-engine/query-engine --bin query-engine
	cargo_src_install --path prisma-fmt --bin prisma-fmt
	# for bin in schema-engine query-engine prisma-fmt; do
	# 	dobin "$(cargo_target_dir)/${bin}"
	# done
}
