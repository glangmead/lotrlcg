#!/usr/bin/env python
import argparse
import os
import json
import glob
import codecs
import re
import subprocess
import xml.etree.ElementTree as ET
import tqdm

parser = argparse.ArgumentParser()
parser.add_argument("--lackeyplugin")
parser.add_argument("--out")
parser.add_argument("--decksonly", action='store_true')
args = parser.parse_args()

IMAGEMAGICK_CARD_CMD_TMPL_VERT = "convert {} \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"466x466\" {} && convert {} -gravity center -background transparent -extent '512x512' {}"
IMAGEMAGICK_THUMB_CMD_TMPL_VERT = "convert {} \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"256x256\" {} && convert {} -gravity west -background transparent -extent '256x256' {}"
IMAGEMAGICK_CARD_CMD_TMPL_HORIZ = "convert {} -crop 600x426+0+0 -rotate \"-90\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"466x466\" {} && convert {} -gravity center -background transparent -extent '512x512' {}"
IMAGEMAGICK_THUMB_CMD_TMPL_HORIZ = "convert {} -crop 600x426+0+0 -rotate \"-90\" \\( +clone -alpha extract \\( -size 20x20 xc:black -draw 'fill white circle 20,20 20,0' -write mpr:arc +delete \\) \\( mpr:arc \\) -gravity northwest -composite \\( mpr:arc -flip \\) -gravity southwest -composite \\( mpr:arc -flop \\) -gravity northeast -composite \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) -alpha off -compose CopyOpacity -composite -resize \"256x256\" {} && convert {} -gravity west -background transparent -extent '256x256' {}"

def run(cmd_parts):
    result = ''
    if not args.decksonly:
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

def write_str_to_file(the_str, path):
    with open(path, 'w') as out:
        out.write(the_str)

def full_lackey_path_to_card_image(lackey_dir, card_dict, filename):
    fullpath = None
    if filename == 'encounter':
        fullpath = "{}/sets/setimages/Core/encounter.jpg".format(lackey_dir)
    elif filename == 'cardback':
        fullpath = "{}/sets/setimages/general/cardback.jpg".format(lackey_dir)
    elif filename == 'spawned':
        fullpath = "{}/sets/setimages/general/spawned.jpg".format(lackey_dir)
    else:
        fullpath_cand = "{}/sets/setimages/{}/{}.jpg".format(lackey_dir, card_dict['set'], filename)
        if os.path.exists(fullpath_cand):
            fullpath = fullpath_cand
        else:
            # PNG format
            fullpath_cand = "{}/sets/setimages/{}/{}.png".format(lackey_dir, card_dict['set'], filename)
        if os.path.exists(fullpath_cand):
            fullpath = fullpath_cand
    if not os.path.exists(fullpath):
        fullpath = None
    return fullpath

def transform_lackey_image_to_cardwarden(lackey_dir, in_path, out_path, out_thumb_path):
    dims = get_image_file_dimensions(in_path)
    #print dims
    if dims[1] > 650:
        cmd_card  = IMAGEMAGICK_CARD_CMD_TMPL_HORIZ.format(in_path, out_path, out_path, out_path)
        cmd_thumb = IMAGEMAGICK_THUMB_CMD_TMPL_HORIZ.format(in_path, out_thumb_path, out_thumb_path, out_thumb_path)
    else:
        cmd_card  = IMAGEMAGICK_CARD_CMD_TMPL_VERT.format(in_path, out_path, out_path, out_path)
        cmd_thumb = IMAGEMAGICK_THUMB_CMD_TMPL_VERT.format(in_path, out_thumb_path, out_thumb_path, out_thumb_path)
    run(cmd_card)
    run(cmd_thumb)

# returns the highest cardwarden id this card has now occupied (it either occupies 1 or two ids depending on if it has a custom back)
def install_card_and_thumb(card_dict, max_cardwarden_id, lackey_dir, cardwarden_ids_by_lackey_name, cardwarden_back_ids_by_lackey_name, cardwarden_out_dir, force_additional_copy=False):

    front_name = card_dict['image_front_no_ext']
    back_name = card_dict['image_back_no_ext']

    if front_name in cardwarden_ids_by_lackey_name:
        front_id = cardwarden_ids_by_lackey_name[front_name]
        if force_additional_copy:
            front_id = max_cardwarden_id + 1
            max_cardwarden_id += 1
    else:
        front_id = max_cardwarden_id + 1
        max_cardwarden_id += 1
        cardwarden_ids_by_lackey_name[front_name] = front_id

    if back_name in cardwarden_ids_by_lackey_name:
        back_id = cardwarden_ids_by_lackey_name[back_name]
    else:
        back_id = max_cardwarden_id + 1
        max_cardwarden_id += 1
        cardwarden_ids_by_lackey_name[back_name] = back_id

    back_path_in = full_lackey_path_to_card_image(lackey_dir, card_dict, back_name)
    back_path_out = "{}/Cards/{}.png".format(cardwarden_out_dir, back_id)
    back_path_thumb_out = "{}/Thumbs/{}.png".format(cardwarden_out_dir, back_id)
    if not os.path.exists(back_path_out) or not os.path.exists(back_path_thumb_out):
        transform_lackey_image_to_cardwarden(lackey_dir, back_path_in, back_path_out, back_path_thumb_out)

    cardwarden_back_ids_by_lackey_name[front_name] = back_id

    front_path_in = full_lackey_path_to_card_image(lackey_dir, card_dict, front_name)
    front_path_out = "{}/Cards/{}.png".format(cardwarden_out_dir, front_id)
    front_path_thumb_out = "{}/Thumbs/{}.png".format(cardwarden_out_dir, front_id)
    if not os.path.exists(front_path_out) or not os.path.exists(front_path_thumb_out):
        transform_lackey_image_to_cardwarden(lackey_dir, front_path_in, front_path_out, front_path_thumb_out)

    meta_path_out_front = "{}/Meta/{}.txt".format(cardwarden_out_dir, front_id)
    if not os.path.exists(meta_path_out_front) or force_additional_copy:
        write_str_to_file("CardBack={}".format(back_id), meta_path_out_front)

    meta_path_out_back = "{}/Meta/{}.txt".format(cardwarden_out_dir, back_id)
    if not os.path.exists(meta_path_out_back):
        write_str_to_file("CardBack={}".format(back_id), meta_path_out_back)

    return max_cardwarden_id

out_dir = args.out

player_types_list = ['Hero', 'Ally', 'Attachment', 'Event', 'Boon']
player_types = set(player_types_list)
encounter_types = set(['Burden', 'Enemy', 'Location', 'Objective', 'Treachery'])
sets_ordered_by_release = ["Core", "HFG", "CATC", "AJTR", "TMAO", "THOEM", "TDM", "RTM", "KAZ",
    "RHG", "RTR", "TWitW", "TLD", "FoS", "SaF", "OHAUH", "TBOLT", "HON", "OTD", "TSF", "TDF",
    "EaAD", "AOO", "TBR", "TBOG", "TSOE", "TMV", "VoI", "TDT", "TTT", "TiT", "TRD", "NiE", "CS",
    "TAC" # not present: 2015- (The Lost Realm, The Treason of Saruman, The Wastes of Eriador, ...)
]

# parse lackey's master CardDataFiles.txt and use that data to decide what's in each Box
type_to_card_back = {
    'Ally': 'cardback',
    'Attachment': 'cardback',
    'Boon': 'cardback',
    'Event': 'cardback',
    'Hero': 'cardback',
    'Burden': 'encounter',
    'Enemy': 'encounter',
    'Location': 'encounter',
    'Objective': 'encounter',
    'Treachery': 'encounter'
}

# get any card by the filename of its front image (without extension)
card_dict_by_image_name = {}
card_dicts = []
# player cards: hierarchical dictionary allowing easy organization:
# set -> sphere -> type -> list of front image filenames
player_card_ids_by_set_sphere_type = {}
# quest and encounter cards:
quests_by_set = {}
quest_name_to_icon_set = {}
quest_name_to_quest_card_ids = {}
card_image_names_by_icon = {}

# for encounter cards we want to parse the # of copies
card_copies_by_id = {}

first_line = True
with codecs.open("{}/sets/CardDataFiles.txt".format(args.lackeyplugin)) as card_database_file:
    for line in card_database_file:
        if first_line:
            first_line = False
            continue
        line = line.rstrip()
        parts = line.split('\t')
        if len(parts) > 5 and len(parts[0]) > 0 and len(parts[1]) > 0 and len(parts[4]) > 0 and len(parts[5]) > 0:
            name = parts[0]
            set_name = parts[1]
            type = parts[4]
            sphere = parts[5]

            # the card count
            count = 1
            count_str = parts[3]
            if len(count_str) > 0:
                count_first_part = re.split(r'[ \(]', count_str)[0]
                count = int(count_first_part)

            try:

                # images
                if ',' in parts[2]:
                    image_front_no_ext = parts[2].split(',')[0]
                    image_back_no_ext = parts[2].split(',')[1]
                else:
                    image_front_no_ext = parts[2]
                    if type in type_to_card_back:
                        image_back_no_ext = type_to_card_back[type]
                    else:
                        image_back_no_ext = image_front_no_ext
                # tsv is inconsistent, sometimes has extensions sometimes not
                image_front_no_ext = image_front_no_ext.replace('.png', '')
                image_back_no_ext = image_back_no_ext.replace('.png', '')
                icon = ''

                if type in encounter_types or type == "Quest":
                    card_copies_by_id[image_front_no_ext] = count
                    # parse icons for each encounter card and quest card
                    encounter_set = sphere
                    is_quest_card = type == "Quest"
                    name_parse = re.match('.*\((.*?)\)[ \-]*(.*)', encounter_set) # "Sphere/Encounter Set(icon)"
                    try:
                        icon = name_parse.group(1)
                        quest_name = name_parse.group(2)
                        #print "{} -> icon |{}|".format(encounter_set, icon)
                        if is_quest_card:
                            icons = re.split(r', ?', icon)
                            quest_name_to_icon_set[quest_name] = sorted(list(set(icons)))
                            if quest_name not in quest_name_to_quest_card_ids:
                                quest_name_to_quest_card_ids[quest_name] = []
                            quest_name_to_quest_card_ids[quest_name].append(image_front_no_ext)
                            if set_name not in quests_by_set:
                                quests_by_set[set_name] = []
                            if quest_name not in quests_by_set[set_name]:
                                quests_by_set[set_name].append(quest_name)
                        else:
                            if icon not in card_image_names_by_icon:
                                card_image_names_by_icon[icon] = []
                            card_image_names_by_icon[icon].append(image_front_no_ext)
                    except:
                        print "error with re: {}".format(name)
            except:
                print("Error parsing line\n{}\n{}".format(line, parts))
                raise
            card_dict = {'name': name, 'set': set_name, 'image_front_no_ext': image_front_no_ext, 'image_back_no_ext': image_back_no_ext, 'type': type, 'icon': icon, 'sphere': sphere}
            card_dicts.append(card_dict)

            if type in player_types:
                if set_name not in player_card_ids_by_set_sphere_type:
                    player_card_ids_by_set_sphere_type[set_name] = {}
                if sphere not in player_card_ids_by_set_sphere_type[set_name]:
                    player_card_ids_by_set_sphere_type[set_name][sphere] = {}
                if type not in player_card_ids_by_set_sphere_type[set_name][sphere]:
                    player_card_ids_by_set_sphere_type[set_name][sphere][type] = []
                #print "indexing a |{}| |{}| |{}|".format(set_name, sphere, type)
                player_card_ids_by_set_sphere_type[set_name][sphere][type].append(image_front_no_ext)

        card_dict_by_image_name[image_front_no_ext] = card_dict

# box1
box1sets = ["Core", "HFG", "CATC", "AJTR", "TMAO", "THOEM", "TDM", "RTM"]
id_to_cardwarden_id = {}
id_to_cardwarden_back_id = {}
max_cardwarden_id = 999

blank_card_dict = {'name': name, 'set': set_name, 'image_front_no_ext': 'cardback', 'image_back_no_ext': 'cardback', 'type': type, 'icon': icon, 'sphere': sphere }

for set in box1sets:
    for sphere in ['Leadership', 'Lore', 'Neutral', 'Spirit', 'Tactics']:
        for type in player_types_list:
            if set in player_card_ids_by_set_sphere_type and sphere in player_card_ids_by_set_sphere_type[set] and type in player_card_ids_by_set_sphere_type[set][sphere]:
                ids = player_card_ids_by_set_sphere_type[set][sphere][type]
                for id in ids:
                    card_dict = card_dict_by_image_name[id]
                    max_cardwarden_id = install_card_and_thumb(card_dict, max_cardwarden_id, args.lackeyplugin, id_to_cardwarden_id, id_to_cardwarden_back_id, args.out)
                # spit out separating image
                max_cardwarden_id = install_card_and_thumb(blank_card_dict, max_cardwarden_id, args.lackeyplugin, id_to_cardwarden_id, id_to_cardwarden_back_id, args.out, force_additional_copy=True)

deck_num = 0
for set in box1sets:
    print "processing {} quests/encounters".format(set)
    for quest in quests_by_set[set]:
        encounter_icons = quest_name_to_icon_set[quest]
        all_quest_card_ids = quest_name_to_quest_card_ids[quest] # start with quest cards
        for icon in encounter_icons:
            images = card_image_names_by_icon[icon]
            all_quest_card_ids.extend(images)
        for image in all_quest_card_ids:
            # spit out the cardwarden info for this image
            card_dict = card_dict_by_image_name[image]
            #(card_dict, max_cardwarden_id, lackey_dir, cardwarden_ids_by_lackey_name, cardwarden_out_dir):
            max_cardwarden_id = install_card_and_thumb(card_dict, max_cardwarden_id, args.lackeyplugin, id_to_cardwarden_id, id_to_cardwarden_back_id, args.out)
        # write deck
        deck_str = "{},".format(quest.replace(' ', ''))
        deck_cardwarden_ids = [0] * 240 # deck lists card front then card back, for each of 120 cards
        cur_index = 0
        for id in all_quest_card_ids:
            count = card_copies_by_id[id]
            cardwarden_front_id = id_to_cardwarden_id[id]
            cardwarden_back_id = id_to_cardwarden_back_id[id]
            print "{}: {} {}={} ({})".format(quest, card_dict_by_image_name[id]['name'], id, id_to_cardwarden_id[id], count)
            for i in range(count):
                deck_cardwarden_ids[cur_index] = cardwarden_front_id
                deck_cardwarden_ids[cur_index + 1] = cardwarden_back_id
                cur_index += 2
        first_id = True
        deck_str += ','.join(["{}".format(id) for id in deck_cardwarden_ids])

        write_str_to_file(deck_str, "{}/Decks/{}.txt".format(args.out, deck_num))
        deck_num += 1

# handy: parse .dek files from plugin, as they also include asides
# for lackey_deck in glob.glob("args.lackeyplugin/decks/.*.dek"):
#     deck_tree = ET.parse(lackey_deck)
#     deck = deck_tree.getroot()
#     raw_name = deck.findall('./meta/title')[0].text
#     deck_name = os.path.basename(lackey_deck).replace('.dek', '')[1:]
#     # since we have room for only 20, skip nightmare decks
#     if deck_name.startswith('N') or deck_name.startswith('E'):
#         continue
#     card_name_id_tuples_by_zonename = {}
#     for zone in deck.findall('./superzone'):
#         zone_name = zone.attrib['name']
#         card_name_id_tuples = []
#         for card in zone.findall('./card'):
#             for cardname_node in card.findall('./name')[0]:
#                 cardname = cardname_node.text
#                 card_id = cardname_node.attrib['id']
#                 card_name_id_tuples.append((cardname, card_id))
#         card_name_id_tuples_by_zonename[zone_name] = card_name_id_tuples
#     order_of_zones_in_cardwarden = ['Quest Deck', 'Aside', 'Encounter Deck']
#     for zone in order_of_zones_in_cardwarden:
