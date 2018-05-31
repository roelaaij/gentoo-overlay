# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils cmake-utils

DESCRIPTION="Mediastreaming library for telephony application"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/${PN}2/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0/3"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
# Many cameras will not work or will crash an application if mediastreamer2 is
# not built with v4l2 support (taken from configure.ac)
IUSE="+alsa amr bindist coreaudio debug doc examples +filters g726 g729 gsm
	  ilbc jpeg libav mkv opengl opus +ortp oss pcap portaudio pulseaudio
	  sdl +speex static-libs test theora upnp v4l video x264 X tools srtp
	  zrtp vpx"
REQUIRED_USE="|| ( oss alsa portaudio coreaudio pulseaudio )
	video? ( || ( opengl sdl X ) )
	zrtp? ( srtp )
	theora? ( video )
	X? ( video )
	v4l? ( video )
	opengl? ( video )"

RDEPEND="alsa? ( media-libs/alsa-lib )
	g726? ( >=media-libs/spandsp-0.0.6_pre1 )
	gsm? ( media-sound/gsm )
	mkv? ( media-libs/bcmatroska2 )
	opus? ( media-libs/opus )
	ortp? ( >=net-libs/ortp-1.0.0 )
	pcap? ( sys-libs/libcap )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.21 )
	speex? ( >=media-libs/speex-1.2_beta3 )
	srtp? ( net-libs/libsrtp )
	zrtp? ( net-libs/bzrtp )
	upnp? ( net-libs/libupnp )
	video? (
		libav? ( >=media-video/libav-9.12:0= )
		!libav? ( >=media-video/ffmpeg-1.2.6-r1:0= )

		opengl? ( media-libs/glew
			virtual/opengl
			x11-libs/libX11 )
		v4l? ( media-libs/libv4l
			sys-kernel/linux-headers )
		theora? ( media-libs/libtheora )
		vpx? ( >=media-libs/libvpx-1.6.0 )
		sdl? ( media-libs/libsdl[video,X] )
		X? ( x11-libs/libX11
			x11-libs/libXv ) )"
DEPEND="${RDEPEND}
	dev-util/intltool
	jpeg? ( media-libs/libjpeg-turbo )
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	opengl? ( dev-util/xxdi )
	test? ( >=dev-util/cunit-2.1_p2[ncurses] )
	g729? ( media-libs/bcg729 )
	X? ( x11-proto/videoproto )"

PDEPEND="amr? ( !bindist? ( media-plugins/mediastreamer-amr ) )
	ilbc? ( media-plugins/mediastreamer-ilbc )
	video? ( x264? ( >=media-plugins/mediastreamer-x264-1.5.3 ) )"

S=${WORKDIR}/${PN}2-${PV}

src_configure() {
	local mycmakeargs=(
		-DENABLE_SHARED=YES
		-DENABLE_STATIC=NO
		-DENABLE_STRICT=NO
		-DENABLE_DOC="$(usex doc)"
		-DENABLE_NON_FREE_CODECS=NO
		-DENABLE_PCAP="$(usex pcap)"
		-DENABLE_RELATIVE_PREFIX=NO
		-DENABLE_TOOLS="$(usex tools)"
		-DENABLE_SRTP="$(usex srtp)"
		-DENABLE_ZRTP="$(usex zrtp)"
		-DENABLE_SOUND=ON
		-DENABLE_MACSND="$(usex coreaudio)"
		-DENABLE_ALSA="$(usex alsa)"
		-DENABLE_PULSEAUDIO="$(usex pulseaudio)"
		-DENABLE_OSS="$(usex oss)"
		-DENABLE_PORTAUDIO="$(usex portaudio)"
		-DENABLE_ANDROIDSND=NO
		-DENABLE_G726="$(usex g726)"
		-DENABLE_G729B_CNG="$(usex g729)"
		-DENABLE_GSM="$(usex gsm)"
		-DENABLE_BV16=NO
		-DENABLE_OPUS="$(usex opus)"
		-DENABLE_ORTP="$(usex ortp)"
		-DENABLE_SPEEX_CODEC="$(usex speex)"
		-DENABLE_SPEEX_DSP="$(usex speex)"
		-DENABLE_RESAMPLE="$(usex speex)"
		-DENABLE_THEORA="$(usex theora)"
		-DENABLE_VPX="$(usex vpx)"
		-DENABLE_UPNP="$(usex upnp)"
		-DENABLE_VIDEO="$(usex video)"
		-DENABLE_GL="$(usex opengl)"
		-DENABLE_GLX="$(usex opengl)"
		-DENABLE_X11="$(usex X)"
		-DENABLE_XV="$(usex X)"
		-DENABLE_V4L="$(usex v4l)"
		-DENABLE_SDL="$(usex sdl)"
		-DENABLE_MKV="$(usex mkv)"
		-DENABLE_VT_H264=NO
		-DENABLE_JPEG="$(usex jpeg)"
		-DENABLE_UNIT_TESTS="$(usex test)"

	)
	cmake-utils_src_configure
}

src_test() {
	cmake-utils_src_test

	cd tester || die
	./mediastreamer2_tester || die
}

src_install() {
	cmake-utils_src_install
	prune_libtool_files

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tester/*.c
	fi
}
