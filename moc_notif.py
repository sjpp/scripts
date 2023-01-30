#!/usr/bin/python3
# |-------------------------------------------------------------
# | Nom         : moc_notif.py
# | Description : Get notified by MOC player
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# -*- coding: utf-8 -*-

import subprocess
import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify
from gi.repository import GLib

moc_song = subprocess.check_output(["mocp", "-Q", "%a - %t"],
                                   universal_newlines=True)
Notify.init("Music On Console")
show_song = Notify.Notification.new("Music On Console", moc_song)

show_song.set_hint("transient", GLib.Variant.new_boolean(True))

show_song.show()
