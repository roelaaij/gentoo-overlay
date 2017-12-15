# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="https://github.com/nlohmann/json"
COMMIT="84ae6187143007cd81bd3c19251c3a2c23118f40"
SRC_URI="https://github.com/vivkin/vjson/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 sparc x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}-${COMMIT}"

PATCHES=( "${FILESDIR}/make-lib.patch" )
