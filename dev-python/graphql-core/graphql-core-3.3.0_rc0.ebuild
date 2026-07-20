# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-/_}"
MY_PV="${PV/_/}"
DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )
PYPI_NO_NORMALIZE=1
inherit distutils-r1

DESCRIPTION="GraphQL-core is a Python port of GraphQL.js"
HOMEPAGE="
	https://github.com/graphql-python/graphql-core/
	https://pypi.org/project/graphql-core/
"

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://github.com/graphql-python/graphql-core"
	inherit git-r3
else
	inherit pypi
	SRC_URI="$(pypi_sdist_url) -> ${P}.tar.gz"
	KEYWORDS="amd64"
	S="${WORKDIR}/${MY_PN}-${MY_PV}"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

BDEPEND=""

EPYTEST_IGNORE=(
	# avoid pytest-benchmark
	"tests/benchmarks/"
)

EPYTEST_PLUGINS=( anyio pytest-asyncio pytest-describe pytest-timeout )
distutils_enable_tests pytest

python_test() {
	# avoid pytest-benchmark
	epytest -o addopts= tests
}
