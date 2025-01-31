# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION="Lightning AI utilities"
HOMEPAGE="
	https://github.com/Lightning-AI/utilities
	https://pypi.org/project/lightning-utilities/
"
SRC_URI="
	https://github.com/Lightning-AI/torchmetrics/releases/download/v${PV}/${P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		<dev-python/lightning-utilities-0.12.0[${PYTHON_USEDEP}]
	')
	>=sci-libs/pytorch-2.0.0[${PYTHON_SINGLE_USEDEP}]
"
