# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mozinfo/mozinfo-0.6.ebuild,v 1.1 2013/08/17 15:46:17 idella4 Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} pypy2_0 )

inherit distutils-r1

DESCRIPTION="Graphviz viewerhttps://pypi.python."
HOMEPAGE="https://pypi.python.org/pypi/xdot"
SRC_URI="https://pypi.python.org/packages/source/x/xdot/xdot-0.5.tar.gz"

LICENSE="|| ( LGPL-2.1 )"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="media-gfx/graphviz[python]"
