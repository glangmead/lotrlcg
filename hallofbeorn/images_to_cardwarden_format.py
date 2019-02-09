#!/usr/bin/env python
import argparse
import os
import json
import glob
import codecs
import re
import subprocess
from bs4 import BeautifulSoup

parser = argparse.ArgumentParser()
parser.add_argument("--imagedir")
parser.add_argument("--outdir")
args = parser.parse_args()

IMAGEMAGICK_CARD_CMD_TMPL_VERT = "convert \"{}\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"466x466\" \"{}\" && convert \"{}\" -gravity center -background transparent -extent '512x512' \"{}\""
IMAGEMAGICK_THUMB_CMD_TMPL_VERT = "convert \"{}\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"256x256\" \"{}\" && convert \"{}\" -gravity west -background transparent -extent '256x256' \"{}\""
IMAGEMAGICK_CARD_CMD_TMPL_HORIZ = "convert \"{}\" -scale 600x426+0+0 -rotate \"-90\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"466x466\" \"{}\" && convert \"{}\" -gravity center -background transparent -extent '512x512' \"{}\""
IMAGEMAGICK_THUMB_CMD_TMPL_HORIZ = "convert \"{}\" -scale 600x426+0+0 -rotate \"-90\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"256x256\" \"{}\" && convert \"{}\" -gravity west -background transparent -extent '256x256' \"{}\""

def run(cmd_parts):
    result = ''
    if ' ' in cmd_parts:
        #print cmd_parts
        os.system(cmd_parts)
    else:
        #print cmd_parts
        result = subprocess.check_output(cmd_parts)
        #print result
    return result

def get_image_file_dimensions(path):
    results = run(["magick", "identify", path])
    if len(results) > 0:
        dims_result = results.split(' ')[2].split('+')[0]
        dims_strings = dims_result.split('x')
        return tuple((int(dims_strings[0]), int(dims_strings[1])))
    return (0,0)

def transform_lackey_image_to_cardwarden(in_path, out_path, out_thumb_path):
    dims = get_image_file_dimensions(in_path)
    #print dims
    if dims[1] < dims[0]:
        cmd_card  = IMAGEMAGICK_CARD_CMD_TMPL_HORIZ.format(in_path, out_path, out_path, out_path)
        cmd_thumb = IMAGEMAGICK_THUMB_CMD_TMPL_HORIZ.format(in_path, out_thumb_path, out_thumb_path, out_thumb_path)
    else:
        cmd_card  = IMAGEMAGICK_CARD_CMD_TMPL_VERT.format(in_path, out_path, out_path, out_path)
        cmd_thumb = IMAGEMAGICK_THUMB_CMD_TMPL_VERT.format(in_path, out_thumb_path, out_thumb_path, out_thumb_path)
    run(cmd_card)
    run(cmd_thumb)

for image_dir in glob.glob("{}/*".format(args.imagedir)):
    subdir_name = os.path.basename(image_dir)
    cards_out = "{}/Cards/{}".format(args.outdir, subdir_name)
    thumbs_out = "{}/Thumbs/{}".format(args.outdir, subdir_name)
    if not os.path.exists(cards_out):
        os.makedirs(cards_out)
    if not os.path.exists(thumbs_out):
        os.makedirs(thumbs_out)
    for in_img in glob.glob("{}/*".format(image_dir)):
        filename = os.path.basename(in_img)
        filename_png = filename.replace(".jpg", ".png")
        out_img = "{}/Cards/{}/{}".format(args.outdir, subdir_name, filename_png)
        out_thumb = "{}/Thumbs/{}/{}".format(args.outdir, subdir_name, filename_png)
        if not os.path.exists(out_img) or not os.path.exists(out_thumb):
            transform_lackey_image_to_cardwarden(in_img, out_img, out_thumb)
