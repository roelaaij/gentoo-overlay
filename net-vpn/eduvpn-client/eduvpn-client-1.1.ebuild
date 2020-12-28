# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License

EAPI=7

PYTHON_COMPAT=( python{3_6,3_7,3_8,3_9} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_P=python-${PN}

DESCRIPTION="eduVPN client"
HOMEPAGE="https://eduvpn.org/"
SRC_URI="https://github.com/eduvpn/${MY_P}/archive/${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/libnotify[introspection]
	net-vpn/networkmanager-openvpn
	dev-libs/gobject-introspection[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_MULTI_USEDEP}]
		dev-python/pynacl[${PYTHON_MULTI_USEDEP}]
		dev-python/requests-oauthlib[${PYTHON_MULTI_USEDEP}]
		dev-python/future[${PYTHON_MULTI_USEDEP}]
		dev-python/python-dateutil[${PYTHON_MULTI_USEDEP}]
		dev-python/pytest[${PYTHON_MULTI_USEDEP}]
		dev-python/pytest-mock[${PYTHON_MULTI_USEDEP}]
		dev-python/qrcode[${PYTHON_MULTI_USEDEP}]
		dev-python/repoze-lru[${PYTHON_MULTI_USEDEP}]
	')"

RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-exclude-tests-install.patch" )

S="${WORKDIR}/${MY_P}-${PV}"

src_prepare() {
	default
	rm Makefile || die
}
