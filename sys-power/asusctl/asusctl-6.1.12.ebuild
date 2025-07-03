# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=8

RUST_MIN_VER="1.82.0"
RUST_MAX_VER="1.85.0"
RUST_NEEDS_LLVM=1
LLVM_COMPAT=( 19 )

inherit llvm-r1 systemd cargo linux-info udev xdg desktop

_PV=${PV//_rc/-RC}
_PVV=`[[ ${_PV} =~ .*"RC".* ]] && echo || echo ${_PV}`
_PN="asusd"

DESCRIPTION="${PN} (${_PN}) is a utility for Linux to control many aspects of various ASUS laptops."
HOMEPAGE="https://asus-linux.org"

SRC_URI="
    https://gitlab.com/asus-linux/${PN}/-/archive/${_PV}/${PN}-${_PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/-/project/20328305/uploads/0f0ff7247d7a63cae89a4a705c78f4ad/vendor_${PN}_${_PV}.tar.xz -> vendor_${PN}_${_PV}.tar.xz
"
LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0 ISC LicenseRef-UFL-1.0 MIT MPL-2.0 OFL-1.1 Unicode-DFS-2016 Unlicense ZLIB"
SLOT="0/6"
KEYWORDS="~amd64"
RESTRICT="mirror test" # tests not working at all (upstream fails as well)
IUSE="+acpi +gfx gnome gui -openrc X"
REQUIRED_USE="gnome? ( gfx )"

RDEPEND="!!sys-power/rog-core
    !!sys-power/asus-nb-ctrl
    >=sys-power/power-profiles-daemon-0.13
    acpi? ( sys-power/acpi_call )
    gui? (
        dev-libs/libayatana-appindicator
        sys-auth/seatd
    )
"
DEPEND="${RDEPEND}
    dev-libs/libusb:1
    !openrc? ( sys-apps/systemd:0= )
    openrc? ( || (
        sys-apps/openrc
        sys-apps/sysvinit
    ) )
	sys-apps/dbus
    media-libs/sdl2-gfx
    gfx? ( >=sys-power/supergfxctl-5.2.1[gnome?] )
    $(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/llvm:${LLVM_SLOT}=
	')
"

src_unpack() {
    cargo_src_unpack
    unpack ${PN}-${_PV/_/.}.tar.gz
    sed -i "1s/.*/Version=\"${_PV}\"/" ${S}/Makefile

    # adding vendor-package
    cd ${S} && unpack vendor_${PN}_${_PV%%_*}.tar.xz
}

src_prepare() {
    require_configured_kernel

    # checking for touchpad dependencies
    k_wrn_touch=""
    linux_chkconfig_present I2C_HID_CORE || k_wrn_touch="${k_wrn_touch}> CONFIG_I2C_HID_CORE not found, should be either builtin or build as module\n"
    linux_chkconfig_present I2C_HID_ACPI || k_wrn_touch="${k_wrn_touch}> CONFIG_I2C_HID_ACPI not found, should be either builtin or build as module\n"
    linux_chkconfig_present HID_ASUS || k_wrn_touch="${k_wrn_touch}> CONFIG_HID_ASUS not found, should be either builtin or build as module\n"
    linux_chkconfig_builtin PINCTRL_AMD || k_wrn_touch="${k_wrn_touch}> CONFIG_PINCTRL_AMD not found, must be builtin\n"
    [[ ${k_wrn_touch} != "" ]] && ewarn "\nKernel configuration issue(s), needed for touchpad support:\n\n${k_wrn_touch}"

	# adding vendor package config
	mkdir -p ${S}/.cargo && cp ${FILESDIR}/${P}-vendor_config ${S}/.cargo/config.toml

    # only build rog-control-center when "gui" flag is set (TODO!)
    ! use gui && eapply "${FILESDIR}/${P}-disable_rog-cc.patch"

    default
    rust_pkg_setup
}

src_configure() {
    # enable X11 compatibility (needs testing)
    use gui && local myfeatures=(
        $(usex X rog-control-center/x11 '')
    )
    cargo_src_configure
}

src_compile() {
    cargo_gen_config
    cargo_src_compile

    # cargo is using a different target-path during compilation (correcting it)
    [ -d `cargo_target_dir` ] && mv -f "`cargo_target_dir`/"* ./target/release/
}

src_install() {
    if use gui; then
        # icons (apps)
        insinto /usr/share/icons/hicolor/512x512/apps/
        doins data/icons/*.png

        # icons (status/notify)
        insinto /usr/share/icons/hicolor/scalable/status/
        doins data/icons/scalable/*.svg
    fi

    insinto /lib/udev/rules.d/
    doins data/${_PN}.rules

    if [ -f data/_asusctl ] && [ -d /usr/share/zsh/site-functions ]; then
        insinto /usr/share/zsh/site-functions
        doins data/_asusctl
    fi

    if ! use openrc; then
        insinto /usr/share/dbus-1/system.d/
        doins data/${_PN}.conf

        systemd_dounit data/${_PN}.service
        systemd_douserunit data/${_PN}-user.service
    else
        newinitd "${FILESDIR}"/asusd.init asusd
    fi

    if use acpi; then
        insinto /etc/modules-load.d
        doins ${FILESDIR}/90-acpi_call.conf
    fi

    use gui && domenu rog-control-center/data/rog-control-center.desktop

    default
}

pkg_postinst() {
    xdg_icon_cache_update
    udev_reload

    use openrc && ewarn "You've set the OpenRC useflag - Expect issues (as this is officially unsupported)!"
}

pkg_postrm() {
    xdg_icon_cache_update
    udev_reload
}
