# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_1{1..3} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the openai API"
HOMEPAGE="https://github.com/openai/openai-python"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE="aio pandas voice"
RDEPEND="
	dev-python/anyio[${PYTHON_USEDEP}]
	dev-python/distro[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jiter[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	aio? (
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/httpx-aiohttp[${PYTHON_USEDEP}] )
	pandas? (
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/pandas-stubs[${PYTHON_USEDEP}] )
	dev-python/websockets[${PYTHON_USEDEP}]
	voice? (
		dev-python/sounddevice[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}] )"

distutils_enable_tests pytest
