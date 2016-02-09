# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE=""

inherit autotools eutils libtool toolchain-funcs versionator python-single-r1

MY_PV=$(replace_all_version_separators '_')
MY_P="${PN}-${PN}-${MY_PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="BitTorrent library written in C++ for *nix"
HOMEPAGE="http://libtorrent.org/"
SRC_URI="https://github.com/arvidn/libtorrent/archive/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE="debug ipv6 ssl python static-libs test examples doc"

RDEPEND="
	>=dev-libs/libsigc++-2.2.2:2
	ssl? ( dev-libs/openssl )
	python? ( ${PYTHON_DEPS}
			  dev-libs/boost[${PYTHON_USEDEP}] )
	"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/python-link-dynamic.patch"
	mkdir "${S}/build-aux"
	cp "${S}/m4/config.rpath" "${S}/build-aux/config.rpath"
	eautoreconf
}

src_configure() {
	# use multi-threading versions of boost libs
	local BOOST_LIBS="--with-boost-system=boost_system-mt \
		--with-boost-python=boost_python-2.7-mt"
	# detect boost version and location, bug 295474
	BOOST_PKG="$(best_version ">=dev-libs/boost-1.34.1")"
	BOOST_VER="$(get_version_component_range 1-2 "${BOOST_PKG/*boost-/}")"
	BOOST_VER="$(replace_all_version_separators _ "${BOOST_VER}")"
	BOOST_INC="${EPREFIX}/usr/include/boost-${BOOST_VER}"

	local LOGGING
	use debug && LOGGING="--enable-logging=verbose"

	econf $(use_enable debug) \
		$(use_enable test tests) \
		$(use_enable examples) \
		$(use_enable python python-binding) \
		$(use_enable ssl encryption) \
		$(use_enable static-libs static) \
		${LOGGING} \
		--with-boost=${BOOST_INC} \
		${BOOST_LIBS}
}

src_install() {
	emake DESTDIR="${D}" install
	use static-libs || find "${D}" -name '*.la' -exec rm -f {} +
	dodoc ChangeLog AUTHORS NEWS README
	if use doc; then
		dohtml docs/*
	fi
}
