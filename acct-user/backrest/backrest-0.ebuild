# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="Backrest service account"
ACCT_USER_ID="399"
ACCT_USER_GROUPS=( backrest )

acct-user_add_deps