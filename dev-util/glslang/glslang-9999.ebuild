# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

EGIT_REPO_URI=( "https://github.com/KhronosGroup/glslang.git" )

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-devel/bison
		dev-cpp/gtest"
RDEPEND="${DEPEND}"
