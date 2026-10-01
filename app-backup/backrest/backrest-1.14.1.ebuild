# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module optfeature systemd tmpfiles

DESCRIPTION="Web UI for restic backups, with scheduling and orchestration"
HOMEPAGE="https://github.com/garethgeorge/backrest"

# Source tarball.
SRC_URI="https://github.com/garethgeorge/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Go module cache, created with:
#   (cd ${S} && GOMODCACHE="${PWD}/go-mod" go mod download -modcacherw)
#   (zips under go-mod/cache/download are scrubbed; the extracted modules and
#   proxy metadata are all go needs offline, and go.sum verification still
#   applies)
#   XZ_OPT='-T0 -9' tar -C go-mod -acf backrest-${PV}-go-mod-cache.tar.xz .
#
# pnpm offline inputs (pnpm 12, the Rust rewrite), created with:
#   (cd ${S}/webui && HOME=<tmp> pnpm install --frozen-lockfile \
#      --ignore-scripts --store-dir <store>)                       # warm-up
#   XZ_OPT='-T0 -9' tar -C <store>        -acf backrest-${PV}-pnpm-store-v11.tar.xz v11
#   XZ_OPT='-T0 -9' tar -C "${XDG_CACHE_HOME:-$HOME/.cache}/pnpm" \
#                        -acf backrest-${PV}-pnpm-metadata.tar.xz v11
# pnpm 12 needs BOTH the v11 content store (index.db + files/) and the
# registry metadata cache -- a store alone fails offline with
# ERR_PNPM_NO_OFFLINE_TARBALL/NO_OFFLINE_META. The tarballs must live on a
# filesystem supporting shared mmaps (virtiofs does not).
#
# All three are unpacked in src_unpack and consumed offline: GOPROXY points
# at an empty file:// dir (any miss fails loudly instead of dialing out),
# pnpm runs with --offline --frozen-lockfile under XDG_CACHE_HOME pointing
# at the unpacked metadata.
SRC_URI+=" ${P}-go-mod-cache.tar.xz"
SRC_URI+=" ${P}-pnpm-store-v11.tar.xz"
SRC_URI+=" ${P}-pnpm-metadata.tar.xz"
# Paraglide (the i18n compiler) loads its message-format plugins over the
# network by default (cdn.jsdelivr.net, via project.inlang/settings.json).
# Vendor the exact plugin bundles instead: the tarball holds the files
# fetched from the pinned CDN URLs, unpacked into webui/inlang/, and
# settings.json is rewritten to the local paths in src_unpack.
SRC_URI+=" ${P}-inlang-plugins.tar.xz"

S="${WORKDIR}/${P}"

LICENSE="GPL-3"
# Licenses of the statically linked Go dependencies and of the npm packages
# bundled into the embedded webui.
LICENSE+=" MIT BSD BSD-2 ISC Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="tray"

# restic is the backing binary; backrest otherwise self-downloads it at
# runtime, which we must not allow. >=0.19.1 matches upstream's pinned
# RequiredResticVersion (internal/resticinstaller/resticinstaller.go).
RDEPEND="
	>=app-backup/restic-0.19.1
	acct-user/backrest
"
tray_deps="
	app-accessibility/at-spi2-core:2
	dev-libs/glib:2
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"
RDEPEND+="${tray_deps}"
DEPEND+="${tray_deps}"

BDEPEND="
	>=dev-lang/go-1.26.0
	>=dev-util/pnpm-12.8.1
	net-libs/nodejs
"

RESTRICT="test"

# backrest is a static go binary built with -s -w.
QA_FLAGS_IGNORED="usr/bin/backrest"
QA_PRESTRIPPED="usr/bin/backrest"

_backrest_pnpm_offline() {
	local store="${1}"
	local -x PNPM_HOME="${WORKDIR}/pnpm-home"
	# pnpm 12 stores its npm registry metadata under $XDG_CACHE_HOME/pnpm;
	# point it at the unpacked metadata distfile so no metadata fetch is
	# attempted (a fetch inside portage's network sandbox dies with
	# ERR_PNPM_META_FETCH_FAIL).
	local -x XDG_CACHE_HOME="${WORKDIR}/pnpm-cache"
	pushd "${S}/webui" >/dev/null || die
	# --frozen-lockfile: install exactly the versions pinned by
	# pnpm-lock.yaml.
	# --offline: resolve everything from the given store; fail on a miss
	# instead of touching the network.
	# --ignore-scripts: packages must not run lifecycle scripts.
	pnpm install \
		--frozen-lockfile \
		--offline \
		--ignore-scripts \
		--trust-lockfile \
		--store-dir "${store}" \
		|| die "pnpm install (offline) failed"

	# Paraglide i18n compiler, then the vite build. BACKREST_BUILD_VERSION is
	# baked into the UI by vite.config.ts (define: process.env.*); the
	# upstream "build" script sets UI_OS=unix via cross-env.
	BACKREST_BUILD_VERSION="v${PV}" UI_OS=unix pnpm run compile-i18n \
		|| die "webui i18n compile failed"
	BACKREST_BUILD_VERSION="v${PV}" UI_OS=unix pnpm run build \
		|| die "webui build failed"
	popd >/dev/null || die
}

src_unpack() {
	default

	# Go module cache into the location go-module.eclass expects
	# (GOMODCACHE="${WORKDIR}/go-mod"), with GOPROXY pointed at an empty
	# directory so any missing module fails loudly instead of hanging.
	mkdir -p "${WORKDIR}/go-mod" || die
	tar -C "${WORKDIR}/go-mod" -xf "${DISTDIR}/${P}-go-mod-cache.tar.xz" || die
	mkdir -p "${T}/go-proxy-empty" || die
	export GOPROXY="file://${T}/go-proxy-empty"

	# pnpm v11 store (index.db + files/) and the npm metadata cache: both are
	# required offline (see SRC_URI comments).
	mkdir -p "${WORKDIR}/pnpm-store" "${WORKDIR}/pnpm-cache/pnpm" || die
	tar -C "${WORKDIR}/pnpm-store" -xf "${DISTDIR}/${P}-pnpm-store-v11.tar.xz" || die
	tar -C "${WORKDIR}/pnpm-cache/pnpm" -xf "${DISTDIR}/${P}-pnpm-metadata.tar.xz" || die
	tar -C "${S}/webui" -xf "${DISTDIR}/${P}-inlang-plugins.tar.xz" || die
	# Point paraglide at the vendored plugin bundles (upstream settings
	# reference cdn.jsdelivr.net URLs; an offline compile would otherwise
	# drop plugin-derived messages from the generated UI).
	sed -e 's#https://cdn.jsdelivr.net/npm/@inlang/plugin-message-format@4/dist/index.js#./inlang/plugin-message-format.js#' \
		-e 's#https://cdn.jsdelivr.net/npm/@inlang/plugin-m-function-matcher@2/dist/index.js#./inlang/plugin-m-function-matcher.js#' \
		-i "${S}/webui/project.inlang/settings.json" || die "patching inlang settings failed"
	_backrest_pnpm_offline "${WORKDIR}/pnpm-store"
}

src_configure() {
	go-env_set_compile_environment
}

src_compile() {
	if use tray; then
		# The tray build tag switches main() to start a StatusNotifierItem
		# (freedesktop systray) icon next to the server. On linux the
		# fyne.io/systray implementation is pure Go over D-Bus; the cgo'd
		# dependencies in that ebuild provide the toolkit libs it binds the
		# desktop environment through.
		tray_tags="-tags tray"
	else
		tray_tags=""
	fi

	export CGO_ENABLED=0
	local -a goargs=(
		-trimpath
		${tray_tags}
		-ldflags "-s -w -X main.version=${PV}"
		-o backrest
		./cmd/backrest
	)
	ego build "${goargs[@]}" || die "go build failed"
}

src_install() {
	dobin backrest
	einstalldocs

	# Use the system restic binary so nothing is downloaded at runtime:
	# internal/resticinstaller reads BACKREST_RESTIC_COMMAND first and the
	# OpenRC service exports it from this conf.d file.
	newconfd "${FILESDIR}/backrest.confd" backrest
	newinitd "${FILESDIR}/backrest.initd" backrest

	# systemd unit for the server (headless); a tray user runs backrest from
	# their desktop session via an autostart entry instead.
	systemd_dounit "${FILESDIR}/backrest.service"

	keepdir /var/lib/backrest
	fowners backrest:backrest /var/lib/backrest
	fperms 0750 /var/lib/backrest
}

pkg_postinst() {
	einfo "The backrest web UI binds 127.0.0.1:9898 by default; change it"
	einfo "via /etc/conf.d/backrest (BACKREST_PORT) or a systemd override."
	einfo "Data dir: /var/lib/backrest (BACKREST_DATA)."
	if use tray; then
		optfeature "desktop notifications (tray icon actions)" \
			x11-misc/xdg-utils
	fi
}
