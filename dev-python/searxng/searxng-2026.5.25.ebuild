# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_1{1..4} )

inherit distutils-r1

DESCRIPTION="SearXNG is a free internet metasearch engine which aggregates results from various search services and databases. Users are neither tracked nor profiled."
HOMEPAGE="https://github.com/searxng/searxng https://docs.searxng.org"

SEARXNG_COMMIT="28ef4f7447debd6f988963c80b3ad15046c65908"
MY_P="${PN}-${SEARXNG_COMMIT}"
SRC_URI="https://github.com/searxng/searxng/archive/${SEARXNG_COMMIT}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="server"
RDEPEND="server? ( dev-python/granian )"

RDEPEND="
	${DEPEND}
	acct-group/valkey
	acct-user/valkey
"

BDEPEND="
	acct-group/valkey
	acct-user/valkey
"

S=${WORKDIR}/${MY_P}

src_install() {
	insinto /etc/searxng
	doins utils/templates/etc/searxng/settings.yml
	doins searx/limiter.toml
	use prefix || fowners -R searxng:searxng /etc/searxng /etc/searxng/{searxng,sentinel}.conf
	fperms 0750 /etc/searxng
	fperms 0644 /etc/searxng/settings.yml

}

distutils_enable_tests pytest
