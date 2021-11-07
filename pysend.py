#!/usr/bin/python3
# -*- coding: utf-8 -*-

import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify
from gi.repository import GLib
from mpd import MPDClient

# Définition de la connexion au serveur MPD :
client = MPDClient()
client.timeout = 10
client.idletimeout = None
client.connect("localhost", 6600)

# Récupération du dict. contenant les infos de la chanson en cours :
mpd_song = MPDClient.currentsong(client)

# Extraction des infos voulues et construction de la chaîne à afficher :
try:
    s_artist = mpd_song['artist']
except KeyError:
    s_artist = ""
try:
    s_title = mpd_song['title']
except KeyError:
    s_title = ""
try:
    s_album = mpd_song['album']
except KeyError:
    s_album = ""

s_notification = s_artist + " - " + s_title + " - (" + s_album +")"

# Création de la notification :
Notify.init("Music Player Demon")
show_song = Notify.Notification.new("Music Player Demon", s_notification,
                                    icon="/home/sjpp/.icons/Vivacious-Colors/apps/scalable/deadbeef.svg")

show_song.set_hint("transient", GLib.Variant.new_boolean(True))

show_song.show()
