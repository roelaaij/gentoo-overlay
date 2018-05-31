# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit scons-utils toolchain-funcs flag-o-matic

SERF_SHA=8eac95fb734c4d156156e11b8301527aa8544ca3
DESCRIPTION="HTTP client library"
HOMEPAGE="https://serf.apache.org/"
SRC_URI="https://github.com/apache/serf/archive/${SERF_SHA}.zip -> ${P}.zip"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris"
IUSE="kerberos static-libs libressl"

RDEPEND="dev-libs/apr:1=
	dev-libs/apr-util:1=
	!libressl? ( dev-libs/openssl:0= ) libressl? ( dev-libs/libressl:0= )
	sys-libs/zlib:0=
	kerberos? ( virtual/krb5 )"
DEPEND="${RDEPEND}
	>=dev-util/scons-2.3.0"

S=${WORKDIR}/${PN}-${SERF_SHA}

PATCHES="
	${FILESDIR}/${PN}-1.4.0-static-lib.patch
	${FILESDIR}/${PN}-1.4.0-rpath.patch
"

src_prepare() {

	# https://code.google.com/p/serf/issues/detail?id=133
	sed -e "/env.Append(CCFLAGS=\['-O2'\])/d" -i SConstruct

	# need limits.h for PATH_MAX (only when EXTENSIONS is enabled)
	[[ ${CHOST} == *-solaris* ]] && append-cppflags -D__EXTENSIONS__

	default
}

src_compile() {
	MYSCONS=(
		PREFIX="${EPREFIX}/usr"
		LIBDIR="${EPREFIX}/usr/$(get_libdir)"
		# These config scripts are sent through a shell with an empty env
		# which breaks the SYSROOT usage in them.  Set the vars inline to
		# avoid that.
		APR="SYSROOT='${SYSROOT}' ${SYSROOT}${EPREFIX}/usr/bin/apr-1-config"
		APU="SYSROOT='${SYSROOT}' ${SYSROOT}${EPREFIX}/usr/bin/apu-1-config"
		BUILD_STATIC=$(usex static-libs)
		AR="$(tc-getAR)"
		RANLIB="$(tc-getRANLIB)"
		CC="$(tc-getCC)"
		CPPFLAGS="${CPPFLAGS}"
		CFLAGS="${CFLAGS}"
		LINKFLAGS="${LDFLAGS}"
	)

	if use kerberos; then
		myesconsargs+=( GSSAPI="${SYSROOT}${EPREFIX}/usr/bin/krb5-config" )
	fi

	escons "${MYSCONS[@]}"
}

src_test() {
	escons check
}

src_install() {
	escons install --install-sandbox="${D}"
}
