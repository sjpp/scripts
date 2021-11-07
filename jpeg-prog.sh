#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : jpeg-prog.sh
# | Description : Apply JPEG optimization to reduce image size
# |             : useful for the blog
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

in_path=$1
out_path=$2

for i in $in_path/*; do
  out_file=$(basename $i)
  jpegtran -optimize -outfile $out_path/$out_file $i
  jpegtran -progressive -outfile $out_path/$out_file $i
done
