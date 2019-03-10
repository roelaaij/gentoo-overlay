# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
#inherit python-any-r1 cmake-utils virtualx multibuild git-r3
inherit cmake-utils git-r3

DESCRIPTION="Telegram binding for Qt"
HOMEPAGE="https://github.com/Kaffeine/telegram-qt"
EGIT_REPO_URI="https://github.com/Kaffeine/telegram-qt.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="client doc server"

RDEPEND="
		dev-qt/qtcore
		dev-qt/qtdbus
		dev-qt/qtnetwork
		doc? ( dev-qt/qdoc )
"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.12
"

DOCS=( LICENSE.LGPL README.md )

src_configure() {
	local mycmakeargs=(
		-DENABLE_TESTS=OFF
		-DBUILD_CLIENT="$(usex client)"
		-DENABLE_QCH_BUILD="$(usex doc)"
		-DBUILD_SERVER="$(usex server)"
		-DBUILD_GENERATOR=ON
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
