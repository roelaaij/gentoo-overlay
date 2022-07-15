# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cuDNN"
SRC_URI="
	cuda10-2? ( cudnn-linux-x86_64-${PV}_cuda10.2-archive.tar.xz )
	cuda11-5? ( cudnn-linux-x86_64-${PV}_cuda11.6-archive.tar.xz )
	cuda11-6? ( cudnn-linux-x86_64-${PV}_cuda11.6-archive.tar.xz )
	cuda11-7? ( cudnn-linux-x86_64-${PV}_cuda11.6-archive.tar.xz )"

LICENSE="NVIDIA-cuDNN"
SLOT="0/8"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cuda10-2 cuda11-5 cuda11-6 +cuda11-7"
REQUIRED_USE="^^ ( cuda10-2 cuda11-5 cuda11-6 cuda11-7 )"
RESTRICT="fetch"

RDEPEND="
	cuda10-2? ( =dev-util/nvidia-cuda-toolkit-10.2* )
	cuda11-5? ( =dev-util/nvidia-cuda-toolkit-11.5* )
	cuda11-6? ( =dev-util/nvidia-cuda-toolkit-11.6* )
	cuda11-7? ( =dev-util/nvidia-cuda-toolkit-11.7* )"

QA_PREBUILT="*"

src_unpack() {
	default
	# The binary & source dirs are slightly diff.
	use cuda10-2 && S="${WORKDIR}/cudnn-linux-x86_64-${PV}_cuda10.2-archive"
	(use cuda11-5 || use cuda11-6 || use cuda11-7) && S="${WORKDIR}/cudnn-linux-x86_64-${PV}_cuda11.6-archive"
}

src_install() {
	insinto /opt/cuda
	doins LICENSE

	insinto /opt/cuda/targets/x86_64-linux
	doins -r include

	insinto /opt/cuda/targets/x86_64-linux/lib
	doins -r lib/.
}
