# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
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
	dev-libs/gobject-introspection
	net-vpn/wireguard-tools
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pynacl[${PYTHON_USEDEP}]
		dev-python/requests-oauthlib[${PYTHON_USEDEP}]
		dev-python/future[${PYTHON_USEDEP}]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		dev-python/qrcode[${PYTHON_USEDEP}]
		dev-python/repoze-lru[${PYTHON_USEDEP}]
	')"

RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-exclude-tests-install.patch" )

S="${WORKDIR}/${MY_P}-${PV}"

src_prepare() {
	default
	rm Makefile || die
}
