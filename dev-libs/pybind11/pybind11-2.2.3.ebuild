# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit cmake-utils python-any-r1

DESCRIPTION="Lightweight library that exposes C++ types in Python and vice versa"
HOMEPAGE="https://github.com/wjakob/pybind11"
SRC_URI="https://github.com/pybind/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc man info test"

RDEPEND="info? ( sys-apps/texinfo )"
DEPEND="
	${PYTHON_DEPS}
"

python_check_deps() {
	if use doc || use man || use info; then
		has_version "dev-python/sphinx[${PYTHON_USEDEP}]"
		has_version "dev-python/breathe[${PYTHON_USEDEP}]"
	fi
}

src_configure() {
		local mycmakeargs=(
				-DPYBIND11_TEST=$(usex test)
		)
		cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc || use man || use info; then
		cd docs || die
		emake $(use doc && echo html) $(use man && echo man) $(use info && echo info)
	fi
}

src_install() {
	cmake-utils_src_install

	dodoc README.md
	use doc && dodoc -r docs/.build/html
	use man && doman docs/.build/man/pybind11.1
	use info && doinfo docs/.build/texinfo/pybind11.info
}
