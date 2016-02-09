# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils wxwidgets autotools versionator subversion

IUSE="alsa ffmpeg flac id3tag jack ladspa libsamplerate midi mp3 sbsms soundtouch twolame vamp vorbis"

MY_PV=$(replace_version_separator 3 -)
MY_P="${PN}-src-${MY_PV}-beta"
MY_T="${PN}-minsrc-${MY_PV}-beta"
DESCRIPTION="Free crossplatform audio editor"
HOMEPAGE="http://audacity.sourceforge.net/"
ESVN_REPO_URI="http://${PN}.googlecode.com/svn/${PN}-src/trunk/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
RESTRICT="test"

COMMON_DEPEND="x11-libs/wxGTK:3.0[X]
	>=app-arch/zip-2.3
	>=media-libs/libsndfile-1.0.0
	dev-libs/expat
	libsamplerate? ( >=media-libs/libsamplerate-0.1.2 )
	vorbis? ( >=media-libs/libvorbis-1.0 )
	mp3? ( >=media-libs/libmad-0.14.2b )
	flac? ( >=media-libs/flac-1.2.0[cxx] )
	id3tag? ( media-libs/libid3tag )
	soundtouch? ( >=media-libs/libsoundtouch-1.3.1 )
	vamp? ( >=media-libs/vamp-plugin-sdk-2.0 )
	twolame? ( media-sound/twolame )
	ffmpeg? ( virtual/ffmpeg )
	alsa? ( media-libs/alsa-lib )
	jack? ( >=media-sound/jack-audio-connection-kit-0.103.0 )"

RDEPEND="${COMMON_DEPEND}
	mp3? ( >=media-sound/lame-3.70 )"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"

REQUIRED_USE="soundtouch? ( midi )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	echo "${ESVN_REPO_URI}"
	subversion_src_unpack
	cd "${ESVN_STORE_DIR}"
}

src_prepare() {
	epatch_user

	AT_M4DIR="${S}/m4" eautoreconf
}

src_configure() {
	WX_GTK_VER="3.0"
	need-wxwidgets unicode
	local myconf

	if use sbsms && use soundtouch ; then
		echo
		einfo "You have USE='soundtouch sbsms' It is not possible to use both, so"
		einfo "SOUNDTOUCH has been selected by default."
		echo
		myconf="${myconf}"
	elif use sbsms && ! use soundtouch ; then
		myconf="${myconf} --with-sbsms"
	else
		myconf="${myconf}"
	fi

	# * always use system libraries if possible
	# * options listed in the order that configure --help lists them
	# * if libsamplerate not requested, use libresample instead.
	econf \
		--with-libsndfile=system \
		--with-expat=system \
		--enable-unicode \
		--enable-nyquist \
		--enable-gtk3
		$(use_enable ladspa) \
		$(use_with libsamplerate) \
		$(use_with !libsamplerate libresample) \
		$(use_with vorbis libvorbis) \
		$(use_with mp3 libmad) \
		$(use_with flac libflac) \
		$(use_with id3tag libid3tag) \
		$(use_with soundtouch) \
		$(use_with vamp libvamp) \
		$(use_with twolame libtwolame) \
		$(use_with ffmpeg) \
		$(use_with midi) \
		$(use_with alsa) \
		$(use_with jack) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die

	# Remove bad doc install
	rm -rf "${D}"/usr/share/doc

	# Install our docs
	dodoc README.txt
}
