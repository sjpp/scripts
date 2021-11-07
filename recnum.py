#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# |-------------------------------------------------------------
# | Name        : recnum.py
# | Description : This script rename files or reorder photographs
# |             : according to shoot date in the following format
# |             : dirname_0X.ext
# | Auteur      : Sébastien Poher 
# | Mise à jour : 29/05/2017
# | Licence     : GNU GLPv2 or newer
# |-------------------------------------------------------------

# |-----------------------------------------------------------
# | Usage :
# | recnum.py /path/to/folder
# |-----------------------------------------------------------

import os
import sys
import getopt
from mimetypes import guess_type
import pyexiv2
from collections import OrderedDict

def get_mimetype(file):
    """check file mimetype, return fail if not an image"""
    try:
        mt = guess_type(file)[0]
        if "image" in mt:
            return 0
    except TypeError:
        return 1

def get_shotdate(f):
    """get photography shot date, use it as img file attribute"""
    metadata = pyexiv2.ImageMetadata(f)
    metadata.read()
    d = "Exif.Photo.DateTimeOriginal"
    try:
        dval = metadata[d].value
    except:
        print("Aucune date trouvée pour :", f)
        # Set empty metadata if no date found:
        dval = ""
        metadata.write()
    return dval

def do_rename(d, f, i):
    """rename files form dict (sorted_myd) keys"""
    filepath = os.path.join(d, f)
    fdir = os.path.dirname(f)
    try:
        # If there's an extension, keep it
        EXT = "." + filepath.split(".")[1]
    except IndexError:
        EXT = ""
    if i <= 9:
        # Prepend with 0 to keep file order
        os.rename(filepath, os.path.join(
            d, fdir, fdir + "_0" + str(i) + EXT))
    else:
        os.rename(filepath, os.path.join(
            d, fdir, fdir + "_" + str(i) + EXT))

def main(args):
# Check if arg is passed
    if len(args) != 3:
        print("Usage : recnum.py [-f|-i|h] /chemin/dossier/cible")
        sys.exit(1)
    else:
        FULL_DIR = args[2]

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hfi", ["help", "fichiers",
        "images"])
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)

    # allow relative 'here' path:
    if FULL_DIR == ".":
        FULL_DIR = os.getcwd()

# Prevent drama and lots of tears
    if FULL_DIR == os.path.expanduser("~"):
        print("\nAttention, vous aller renommer tous les fichiers \
    de votre dossier personnel ce qui aura pour effet de casser votre système \
    (en gros) !")
        sys.exit(1)

    if "/net" in FULL_DIR:
        print("\nIl est interdit de lancer ce script dans un partage.")
        sys.exit(1)

    for o, a in opts:
        if o in ("-h", "--help"):
            print("Usage : recnum.py [-f|-i|h] /chemin/dossier/cible")
        elif o in ("-i", "--images"):
            # Walk through dir passed as arg
            for dirpath, dirs, files in os.walk(FULL_DIR):
                for d in dirs:
                    # for each subdir create a dict with filepath : shootdate
                    myd = {}
                    # get list of files in current subdir :
                    file_list = os.listdir(os.path.join(dirpath, d))
                    for f in file_list:
                        fp = os.path.join(d, f)
                        # if file is dotfile or a directory, don't treat it :
                        if f[0] == "." or os.path.isdir(os.path.join(dirpath, fp)):
                            continue
                        # if it's a regular file, check if it's an image :
                        if get_mimetype(f) == 0 :
                            # if so, write its name and shootdate to dict :
                            fd = get_shotdate(os.path.join(dirpath, fp))
                            myd[fp] = fd
                    # create a new dict sorted by shootdate :
                    myod = OrderedDict(sorted(myd.items(), key=lambda t: t[1]))
                    # rename each file according to the new order :
                    for i, item in enumerate(myod.items()):
                        do_rename(dirpath, item[0], i+1)

        elif o in ("-f", "--fichiers"):

            # Walk through dir passed as arg
            for dirpath, dirs, files in os.walk(FULL_DIR):
                i = 1
                for f in sorted(files):
                    if f[0] == ".":
                        continue
                    try:
                        # If there's an extension, keep it
                        EXT = "." + f.split(".")[1]
                    except IndexError:
                        EXT = ""
                    if i < 9:
                        # Prepend with 0 to keep file order
                        os.rename(os.path.join(dirpath, f), os.path.join(
                            dirpath, os.path.basename(
                                dirpath) + "_0" + str(i) + EXT))
                        i += 1
                    else:
                        os.rename(os.path.join(dirpath, f), os.path.join(
                            dirpath, os.path.basename(
                                dirpath) + "_" + str(i) + EXT))
                        i += 1

if __name__ == '__main__':
    sys.exit(main(sys.argv))
