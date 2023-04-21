# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )

inherit go-module distutils-r1

DESCRIPTION="EduVPN common code"
HOMEPAGE="https://github.com/eduvpn/eduvpn-common"
SRC_URI="https://github.com/eduvpn/eduvpn-common/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" eduvpn-common-1.1.0-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

DEPEND="dev-lang/go"

RESTRICT+=" test"

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	emake
	distutils-r1_src_compile
}

python_compile() {
	cd wrappers/python || die
	mkdir -p eduvpn_common/lib || die
	distutils-r1_python_compile
}

src_install() {
	dodoc README.md
	distutils-r1_src_install
}
