# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License

EAPI=7

PYTHON_COMPAT=( python{3_5,3_6} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_P=python-${PN}

DESCRIPTION="eduVPN client"
HOMEPAGE="https://eduvpn.org/"
SRC_URI="https://github.com/eduvpn/${MY_P}/archive/${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/gobject-introspection[${PYTHON_USEDEP}]
	x11-libs/libnotify[introspection]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	net-vpn/networkmanager-openvpn
	dev-python/pynacl[${PYTHON_USEDEP}]
	dev-python/requests-oauthlib[${PYTHON_USEDEP}]
	dev-python/future[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/pytest-mock[${PYTHON_USEDEP}]
	dev-python/repoze-lru[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-exclude-tests-install.patch" )

S="${WORKDIR}/${MY_P}-${PV}"

src_prepare() {
	default
	rm Makefile || die
}
