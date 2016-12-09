# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Does not work with py3 here
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit eutils linux-info python-single-r1 multiprocessing autotools toolchain-funcs versionator

CODENAME="Krypton"
SRC_URI="https://github.com/xbmc/xbmc/archive/17.0b6-${CODENAME}.tar.gz"

DESCRIPTION="Kodi is a free and open source media-player and entertainment hub"
HOMEPAGE="https://kodi.tv/ http://kodi.wiki/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="airplay alsa bluetooth bluray caps cec dbus debug gles java joystick midi mysql nfs +opengl profile pulseaudio rtmp +samba sftp test +texturepacker udisks upnp upower +usb vaapi vdpau webserver +X zeroconf"
# gles/vaapi: http://trac.kodi.tv/ticket/10552 #464306
REQUIRED_USE="
	|| ( gles opengl )
	gles? ( !vaapi )
	vaapi? ( !gles )
	udisks? ( dbus )
	upower? ( dbus )
"

COMMON_DEPEND="${PYTHON_DEPS}
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	airplay? ( app-pda/libplist )
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	cec? ( >=dev-libs/libcec-3.0 )
	dev-libs/libpcre[cxx]
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml[stl]
	>=dev-libs/yajl-2
	dev-python/simplejson[${PYTHON_USEDEP}]
	media-fonts/corefonts
	media-fonts/noto
	media-fonts/roboto
	media-fonts/teletext
	media-fonts/anonymous-pro
	alsa? ( media-libs/alsa-lib )
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/jbigkit
	>=media-libs/libass-0.9.7
	bluray? ( >=media-libs/libbluray-0.7.0 )
	media-libs/libmad
	media-libs/libmodplug
	media-libs/libogg
	media-libs/libpng:0=
	media-libs/libsamplerate
	joystick? ( media-libs/libsdl2 )
	>=media-libs/taglib-1.8
	media-libs/libvorbis
	media-sound/dcadec
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	>=media-video/ffmpeg-2.6:=[encode]
	rtmp? ( media-video/rtmpdump )
	nfs? ( net-fs/libnfs:= )
	webserver? ( net-libs/libmicrohttpd[messages] )
	sftp? ( net-libs/libssh[sftp] )
	net-misc/curl
	samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
	bluetooth? ( net-wireless/bluez )
	dbus? ( sys-apps/dbus )
	caps? ( sys-libs/libcap )
	sys-libs/zlib
	usb? ( virtual/libusb:1 )
	mysql? ( virtual/mysql )
	opengl? (
		virtual/glu
		virtual/opengl
	)
	gles? (
		media-libs/mesa[gles2]
	)
	vaapi? ( x11-libs/libva[opengl] )
	vdpau? (
		|| ( >=x11-libs/libvdpau-1.1 >=x11-drivers/nvidia-drivers-180.51 )
		media-video/ffmpeg[vdpau]
	)
	X? (
		x11-apps/xdpyinfo
		x11-apps/mesa-progs
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
	)
	zeroconf? ( net-dns/avahi )
"
RDEPEND="${COMMON_DEPEND}
	!media-tv/xbmc
	udisks? ( sys-fs/udisks:0 )
	upower? ( || ( sys-power/upower sys-power/upower-pm-utils ) )"
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-lang/swig
	dev-libs/crossguid
	dev-util/gperf
	texturepacker? ( media-libs/giflib )
	X? ( x11-proto/xineramaproto )
	dev-util/cmake
	x86? ( dev-lang/nasm )
	java? ( virtual/jre )
	test? ( dev-cpp/gtest )
	virtual/pkgconfig"

CONFIG_CHECK="~IP_MULTICAST"
ERROR_IP_MULTICAST="
In some cases Kodi needs to access multicast addresses.
Please consider enabling IP_MULTICAST under Networking options.
"

pkg_setup() {
	check_extra_config
	python-single-r1_pkg_setup
}

version=( $(get_version_components) )
if [[ -n ${version[2]} ]]; then
	beta="${version[2]:0:1}${version[2]: -1}"
else
	beta=""
fi
S="${WORKDIR}/xbmc-${version[0]}.${version[1]}${beta}-${CODENAME}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-9999-no-arm-flags.patch #400617
	epatch "${FILESDIR}"/${PN}-9999-texturepacker.patch
	epatch_user #293109

	# some dirs ship generated autotools, some dont
	multijob_init
	local d dirs=(
		tools/depends/native/TexturePacker/src/configure
		$(printf 'f:\n\t@echo $(BOOTSTRAP_TARGETS)\ninclude bootstrap.mk\n' | emake -f - f)
	)
	for d in "${dirs[@]}" ; do
		[[ -e ${d} ]] && continue
		pushd ${d/%configure/.} >/dev/null || die
		AT_NOELIBTOOLIZE="yes" AT_TOPLEVEL_EAUTORECONF="yes" \
		multijob_child_init eautoreconf
		popd >/dev/null
	done
	multijob_finish
	elibtoolize

	tc-env_build emake -f codegenerator.mk

	# Disable internal func checks as our USE/DEPEND
	# stuff handles this just fine already #408395
	export ac_cv_lib_avcodec_ff_vdpau_vc1_decode_picture=yes

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -exec touch -r configure {} +
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)
	# No configure flage for this #403561
	export ac_cv_lib_bluetooth_hci_devid=$(usex bluetooth)

	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-ccache \
		--disable-optimizations \
		--with-ffmpeg=shared \
		$(use_enable alsa) \
		$(use_enable airplay) \
		$(use_enable bluray libbluray) \
		$(use_enable caps libcap) \
		$(use_enable cec libcec) \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable gles) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable mysql) \
		$(use_enable nfs) \
		$(use_enable opengl gl) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable rtmp) \
		$(use_enable samba) \
		$(use_enable sftp ssh) \
		$(use_enable usb libusb) \
		$(use_enable test gtest) \
		$(use_enable texturepacker) \
		$(use_enable upnp) \
		$(use_enable vaapi) \
		$(use_enable vdpau) \
		$(use_enable webserver) \
		$(use_enable X x11) \
		$(use_enable zeroconf avahi)
}

src_compile() {
	emake V=1
}

src_install() {
	default
	rm "${ED}"/usr/share/doc/*/{LICENSE.GPL,copying.txt}* || die

	domenu tools/Linux/kodi.desktop
	newicon media/icon48x48.png kodi.png

	# Remove fontconfig settings that are used only on MacOSX.
	# Can't be patched upstream because they just find all files and install
	# them into same structure like they have in git.
	rm -rf "${ED}"/usr/share/kodi/system/players

	# Replace bundled fonts with system ones.
	rm "${ED}"/usr/share/kodi/addons/skin.estuary/fonts/*.{ttf,txt} || die
	for font in Mono-Regular Sans-Bold Sans-Regular; do
		dosym "/usr/share/fonts/noto/Noto${font}.ttf" \
			  "/usr/share/kodi/addons/skin.estuary/fonts/Noto${font}.ttf"
	done

	dosym /usr/share/fonts/roboto/Roboto-Thin.ttf \
		  /usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf

	rm "${ED}"/usr/share/kodi/addons/skin.estouchy/fonts/*.{ttf,txt} || die
	dosym /usr/share/fonts/noto/NotoSans-Regular.ttf \
		/usr/share/kodi/addons/skin.estouchy/fonts/NotoSans-Regular.ttf

	rm "${ED}"/usr/share/kodi/media/Fonts/arial.ttf || die
	dosym /usr/share/fonts/corefonts/arial.ttf \
		/usr/share/kodi/media/Fonts/arial.ttf
	rm "${ED}"/usr/share/kodi/media/Fonts/teletext.ttf || die
	dosym /usr/share/fonts/teletext/teletext.ttf \
		/usr/share/kodi/media/Fonts/teletext.ttf

	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/Kodi Send/kodi-send.py" kodi-send
}
