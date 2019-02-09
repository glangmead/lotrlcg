#!/usr/bin/env python
import argparse
import os
import json
import glob
import codecs
import re
import subprocess
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("--db")
parser.add_argument("--playersets")
parser.add_argument("--scenariocycles")
parser.add_argument("--difficulty")
parser.add_argument("--outdir")
parser.add_argument("--pngdir") # has "Cards" and "Thumbs" subdirs
args = parser.parse_args()

with codecs.open(args.db, encoding='utf-8') as dbfile:
    db = json.load(dbfile)
player_sets = [set.replace(' ', '-') for set in args.playersets.split(',')]
scenario_cycles = [set.replace(' ', '-') for set in args.scenariocycles.split(',')]

card_id_to_cardwarden_front_id = {}
card_id_to_cardwarden_back_id = {}
cardwarden_id_to_card_id = {}
cardwarden_id_to_image_name = {}

# lets us map from the scenario dict, which only has card ids (names), to the sets dict which has full details
card_id_to_dict = {}

def cardwarden_id(card_dict, current_max_cardwarden_id):
    card_id = card_dict['unique_name']
    if card_id not in card_id_to_cardwarden_front_id or card_id == 'player_back' or card_id == 'encounter_back':
        current_max_cardwarden_id += 1
        card_id_to_cardwarden_front_id[card_id] = current_max_cardwarden_id
    cw_front_id = card_id_to_cardwarden_front_id[card_id]
    if cw_front_id not in cardwarden_id_to_card_id:
        cardwarden_id_to_card_id[cw_front_id] = card_id
    if cw_front_id not in cardwarden_id_to_image_name:
        cardwarden_id_to_image_name[cw_front_id] = '/'.join(card_dict['img_urls'][0].split('/')[-2:]).replace(".jpg", ".png")
        print cardwarden_id_to_image_name[cw_front_id]
    if len(card_dict['img_urls']) == 2:
        if card_id not in card_id_to_cardwarden_back_id:
            current_max_cardwarden_id += 1
            card_id_to_cardwarden_back_id[card_id] = current_max_cardwarden_id
        cw_back_id = card_id_to_cardwarden_back_id[card_id]
        if cw_back_id not in cardwarden_id_to_card_id:
            cardwarden_id_to_card_id[cw_back_id] = card_id
        if cw_back_id not in cardwarden_id_to_image_name:
            cardwarden_id_to_image_name[cw_back_id] = '/'.join(card_dict['img_urls'][1].split('/')[-2:]).replace(".jpg", ".png")
    return current_max_cardwarden_id

def is_player(card_dict):
    if card_dict['unique_name'] == 'player_back':
        return True
    if card_dict['unique_name'] == 'encounter_back':
        return False
    return card_dict['encounter_icon'] == 'None'

def write_str_to_file(the_str, path):
    with open(path, 'w') as out:
        out.write(the_str)


# build a cardwarden box by including player cards from all sets and scenarios from specified sets

# insert the two card backs not included at hallofbeorn
player_back_card = {'unique_name': 'player_back', 'name': 'player_back', 'img_urls': ['me/player_back.jpg']}
card_id_to_dict[player_back_card['name']] = player_back_card
encounter_back_card = {'unique_name': 'player_back', 'name': 'encounter_back', 'img_urls': ['me/encounter_back.png']}
card_id_to_dict[encounter_back_card['name']] = encounter_back_card
current_max_cardwarden_id = cardwarden_id(player_back_card, 999)
current_max_cardwarden_id = cardwarden_id(encounter_back_card, current_max_cardwarden_id)

for set in db['sets']:
    set_cards = set['cards']
    for card in set_cards:
        card_id_to_dict[card['unique_name']] = card
    if set['name'] in player_sets:
        for card in set_cards:
            if is_player(card):
                current_max_cardwarden_id = cardwarden_id(card, current_max_cardwarden_id)
        current_max_cardwarden_id = cardwarden_id(player_back_card, current_max_cardwarden_id)
        current_max_cardwarden_id = cardwarden_id(player_back_card, current_max_cardwarden_id)

deck_strings = []
for scenario_cycle in scenario_cycles:
    for scenario in db['scenarios']:
        cycle = scenario['set'].replace(' ', '-')
        if cycle == scenario_cycle:
            cardwarden_decklist = scenario['name'].replace(' ', '-').replace(',', '')
            encounter_cards = scenario['encounter_cards'][args.difficulty]
            quest_cards = scenario['quest_cards']
            deck_ids = [0] * 240
            cur_index = 0
            for quest_card in quest_cards:
                current_max_cardwarden_id = cardwarden_id(card_id_to_dict[quest_card], current_max_cardwarden_id)
                front_cw_id = card_id_to_cardwarden_front_id[quest_card]
                back_cw_id = 1001
                if quest_card in card_id_to_cardwarden_back_id:
                    back_cw_id = card_id_to_cardwarden_back_id[quest_card]
                deck_ids[cur_index] = front_cw_id
                cur_index += 1
                deck_ids[cur_index] = back_cw_id
                cur_index += 1

            for [encounter_card_name, count] in encounter_cards:
                current_max_cardwarden_id = cardwarden_id(card_id_to_dict[encounter_card_name], current_max_cardwarden_id)
                front_cw_id = card_id_to_cardwarden_front_id[encounter_card_name]
                back_cw_id = 1001
                if encounter_card_name in card_id_to_cardwarden_back_id:
                    back_cw_id = card_id_to_cardwarden_back_id[encounter_card_name]
                for repeat in range(count):
                    deck_ids[cur_index] = front_cw_id
                    cur_index += 1
                    deck_ids[cur_index] = back_cw_id
                    cur_index += 1
            cur_index = 0
            while cur_index < 240:
                cardwarden_decklist += ",{},{}".format(deck_ids[cur_index], deck_ids[cur_index + 1])
                cur_index += 2
            deck_strings.append(cardwarden_decklist)
            print cardwarden_decklist
for i in range(len(deck_strings)):
    write_str_to_file(deck_strings[i], "{}/Decks/{}.txt".format(args.outdir, i))
for i in range(1000, current_max_cardwarden_id + 1):
    card_id = cardwarden_id_to_card_id[i]
    card_image = cardwarden_id_to_image_name[i]
    card_dict = card_id_to_dict[card_id]
    if is_player(card_dict):
        back_id = 1000
    else:
        back_id = 1001
    write_str_to_file("CardBack={}".format(back_id), "{}/Meta/{}.txt".format(args.outdir, i))
    shutil.copy(u"{}/Cards/{}".format(args.pngdir, card_image), u"{}/Cards/{}.png".format(args.outdir, i))
    shutil.copy(u"{}/Thumbs/{}".format(args.pngdir, card_image), u"{}/Thumbs/{}.png".format(args.outdir, i))


# scenario_dict = {'name': scenario_name, 'set': set_name_by_scenario_name[scenario], 'quest_cards': quest_card_names, 'encounter_cards': {'normal': normal_card_tuples, 'easy': easy_card_tuples, 'nightmare': nightmare_card_tuples}}
# card_dict = {'is_unique': is_unique, 'sphere': sphere, 'img_urls': img_urls, 'type': type, 'name': name, 'unique_name': card_name, 'encounter_icon': encounter_set_icon}
# set_dict = {'name': set, 'cards': []}
# db_dict['sets'].append(set_dict)
# db_dict['scenarios'] = scenario_dicts
