# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/wikipedia-mode/wikipedia-mode-0.5-r1.ebuild,v 1.5 2014/02/18 07:05:02 ulm Exp $

EAPI=5

inherit elisp eutils

DESCRIPTION="Mode for editing twiki articles"
HOMEPAGE="http://twiki.org/cgi-bin/view/Plugins/EmacsModeAddOn"
SRC_URI="https://github.com/christopherjwhite/emacs-twiki-mode/archive/${PV}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"

SITEFILE="50${PN}-gentoo.el"

S=${WORKDIR}/emacs-${P}
