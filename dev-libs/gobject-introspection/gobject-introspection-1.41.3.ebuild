# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit gnome2 python-single-r1 toolchain-funcs autotools multilib-minimal

DESCRIPTION="Introspection infrastructure for generating gobject library bindings for various languages"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection/"

LICENSE="LGPL-2+ GPL-2+"
SLOT="0"
IUSE="cairo doctool test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( cairo )
"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

# virtual/pkgconfig needed at runtime, bug #505408
RDEPEND="
	>=dev-libs/gobject-introspection-common-${PV}
	>=dev-libs/glib-2.36:2[${MULTILIB_USEDEP}]
	doctool? ( dev-python/mako )
	virtual/libffi:=[${MULTILIB_USEDEP}]
	virtual/pkgconfig
	!<dev-lang/vala-0.20.0
	${PYTHON_DEPS}
"
# Wants real bison, not virtual/yacc
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.19
	sys-devel/bison
	sys-devel/flex
"
# PDEPEND to avoid circular dependencies, bug #391213
PDEPEND="cairo? ( x11-libs/cairo[glib] )"

pkg_setup() {
	python-single-r1_pkg_setup
}

disable_python_for_x86() {
	# x86 build on AMD64 fails due to missing 32bit python. We just remove the
	# Python parts and those that depend on it as they are not required.
	
	if use amd64 && [ "$ABI" == "x86" ]; then
		einfo "Disabling python support for non-native ABI"
		cd ${BUILD_DIR}
		
		# disable configure checks
		epatch ${FILESDIR}/disable_python.patch
		
		# disable python bindings
		sed -i -e "s/include Makefile-giscanner.am//" Makefile.am || die "sed failed"
		
		# disable stuff that doesn't get installed anyways
		sed -i -e "s/include Makefile-tools.am//" Makefile.am || die "sed failed"
		sed -i -e "s/include Makefile-gir.am//" Makefile.am || die "sed failed"
		
		# disable tests
		sed -i -e "s/SUBDIRS = . docs tests/SUBDIRS = . docs/" Makefile.am || die "sed failed"
		eautoreconf
	fi
}

src_prepare() {
	if ! has_version "x11-libs/cairo[glib]"; then
		# Bug #391213: enable cairo-gobject support even if it's not installed
		# We only PDEPEND on cairo to avoid circular dependencies
		export CAIRO_LIBS="-lcairo -lcairo-gobject"
		export CAIRO_CFLAGS="-I${EPREFIX}/usr/include/cairo"
	fi
	DOCS="AUTHORS CONTRIBUTORS ChangeLog NEWS README TODO"

	# Since we're hacking the build system for differing ABIs we need to copy the
	# sources.  TODO: A better alternative would be to patch in support for using
	# --without-python
	multilib_copy_sources
	multilib_parallel_foreach_abi disable_python_for_x86
	gnome2_src_prepare
}

multilib_src_configure(){
	# Set CC To prevent crosscompiling problems, bug #414105
	CC="$(tc-getCC)" gnome2_src_configure \
		--disable-static \
		YACC=$(type -p yacc) \
		$(use_with cairo) \
		$(use_enable doctool)

	# ugly hack. somehow pkgconfig uses the 64bit .pc file for the x86 part
	if use amd64 && [ "$ABI" == "x86" ]; then
		sed -i -e "/^INSTALL/b; s#/usr/lib64#/usr/lib32#g" Makefile || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	# Prevent collision with gobject-introspection-common
	rm -v "${ED}"usr/share/aclocal/introspection.m4 \
		"${ED}"usr/share/gobject-introspection-1.0/Makefile.introspection || die
	rmdir "${ED}"usr/share/aclocal || die
}
