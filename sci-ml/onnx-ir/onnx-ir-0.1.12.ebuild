# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="An in-memory IR that supports the full ONNX spec, designed for graph construction, analysis and transformation."
HOMEPAGE="https://onnx.ai/ir-py"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/ml-dtypes-0.5.0[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	>=sci-ml/onnx-1.16[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"
