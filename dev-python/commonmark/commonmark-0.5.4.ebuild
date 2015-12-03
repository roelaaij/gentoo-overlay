# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/soappy/soappy-0.12.22.ebuild,v 1.5 2015/05/05 09:38:54 jer Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 python3_3 python3_4)

inherit distutils-r1

MY_PN=CommonMark

DESCRIPTION="python pandoc filters"
HOMEPAGE="https://github.com/rolandshoemaker/CommonMark-py"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc64 ~x86"

RDEPEND="dev-lang/python-exec[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
		dev-python/setuptools[${PYTHON_USEDEP}]"

S="${WORKDIR}/${MY_PN}-${PV}"
