# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake

DESCRIPTION="The vdt mathematical library"
HOMEPAGE="https://github.com/dpiparo/vdt"

SRC_URI="https://github.com/dpiparo/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Strings for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
ARM_CPU_FEATURES=(
		cpu_flags_arm_thumb:armv5te
		cpu_flags_arm_v6:armv6
		cpu_flags_arm_thumb2:armv6t2
		cpu_flags_arm_neon:neon
		cpu_flags_arm_vfp:vfp
		cpu_flags_arm_vfpv3:vfpv3
		cpu_flags_arm_v8:armv8
)
ARM_CPU_REQUIRED_USE="
		arm64? ( cpu_flags_arm_v8 )
		cpu_flags_arm_v8? (  cpu_flags_arm_vfpv3 cpu_flags_arm_neon )
		cpu_flags_arm_neon? ( cpu_flags_arm_thumb2 cpu_flags_arm_vfp )
		cpu_flags_arm_vfpv3? ( cpu_flags_arm_vfp )
		cpu_flags_arm_thumb2? ( cpu_flags_arm_v6 )
		cpu_flags_arm_v6? ( cpu_flags_arm_thumb )
"

X86_CPU_FEATURES_RAW=( 3dnow:amd3dnow 3dnowext:amd3dnowext aes:aesni avx:avx avx2:avx2 fma3:fma3 fma4:fma4 mmx:mmx mmxext:mmxext sse:sse sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4 sse4_2:sse42 xop:xop )
X86_CPU_FEATURES=( ${X86_CPU_FEATURES_RAW[@]/#/cpu_flags_x86_} )
X86_CPU_REQUIRED_USE="
		cpu_flags_x86_avx2? ( cpu_flags_x86_avx )
		cpu_flags_x86_fma4? ( cpu_flags_x86_avx )
		cpu_flags_x86_fma3? ( cpu_flags_x86_avx )
		cpu_flags_x86_xop?  ( cpu_flags_x86_avx )
		cpu_flags_x86_avx?  ( cpu_flags_x86_sse4_2 )
		cpu_flags_x86_aes? ( cpu_flags_x86_sse4_2 )
		cpu_flags_x86_sse4_2?  ( cpu_flags_x86_sse4_1 )
		cpu_flags_x86_sse4_1?  ( cpu_flags_x86_ssse3 )
		cpu_flags_x86_ssse3?  ( cpu_flags_x86_sse3 )
		cpu_flags_x86_sse3?  ( cpu_flags_x86_sse2 )
		cpu_flags_x86_sse2?  ( cpu_flags_x86_sse )
		cpu_flags_x86_sse?  ( cpu_flags_x86_mmxext )
		cpu_flags_x86_mmxext?  ( cpu_flags_x86_mmx )
		cpu_flags_x86_3dnowext?  ( cpu_flags_x86_3dnow )
		cpu_flags_x86_3dnow?  ( cpu_flags_x86_mmx )
"

CPU_FEATURES_MAP=(
		${ARM_CPU_FEATURES[@]}
		${X86_CPU_FEATURES[@]}
)
IUSE="${CPU_FEATURES_MAP[@]%:*}"

CPU_REQUIRED_USE="
		${ARM_CPU_REQUIRED_USE}
		${X86_CPU_REQUIRED_USE}
"

PATCHES=( "${FILESDIR}/fix-install-dirs.patch" )

src_configure() {
	local mycmakeargs=(
		-DAVX=$(usex cpu_flags_x86_avx)
		-DSSE=$(usex cpu_flags_x86_sse4_2)
		-DAVX2=$(usex cpu_flags_x86_avx2)
		-DFMA=$(usex cpu_flags_x86_fma3)
		-DNEON=$(usex cpu_flags_arm_neon)
	)

	cmake_src_configure
}
