# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_1{1..3} )

inherit distutils-r1 pypi

DESCRIPTION="FastAPI framework, high performance, easy to learn, fast to code, ready for production"
HOMEPAGE="None"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RDEPEND="
	dev-python/starlette[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/typing-inspection[${PYTHON_USEDEP}]
	dev-python/annotated-doc[${PYTHON_USEDEP}]
	dev-python/fastapi-cli[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/python-multipart[${PYTHON_USEDEP}]
	dev-python/email-validator[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/pydantic-settings[${PYTHON_USEDEP}]
	dev-python/pydantic-extra-types[${PYTHON_USEDEP}]
	dev-python/fastapi-cli[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/python-multipart[${PYTHON_USEDEP}]
	dev-python/email-validator[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/pydantic-settings[${PYTHON_USEDEP}]
	dev-python/pydantic-extra-types[${PYTHON_USEDEP}]
	dev-python/fastapi-cli[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/python-multipart[${PYTHON_USEDEP}]
	dev-python/itsdangerous[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/ujson[${PYTHON_USEDEP}]
	dev-python/orjson[${PYTHON_USEDEP}]
	dev-python/email-validator[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/pydantic-settings[${PYTHON_USEDEP}]
	dev-python/pydantic-extra-types[${PYTHON_USEDEP}]"
distutils_enable_tests pytest
