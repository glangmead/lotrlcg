#!/usr/bin/env python
import argparse
import os
import json
import codecs
from bs4 import BeautifulSoup

parser = argparse.ArgumentParser()
parser.add_argument("--crawl")
args = parser.parse_args()

scenarios = []
set_name_by_scenario_name = {}
encounter_page_path = "{}/LotR/Scenarios/index.html".format(args.crawl)
with codecs.open(encounter_page_path, encoding='utf-8') as encounter_list_file:
    encounters_parse = BeautifulSoup(encounter_list_file, 'html.parser')
    for a in encounters_parse.find_all('a'):
        target = a.get('href')
        if '/Cards/Scenarios' in target:
            scenario_name = target.split('/')[-1]
            set_name = 'None'
            scenarios.append(scenario_name)
            # search backward for a div with a subscenario class, else h3 which is the set name
            for prev_node in a.find_all_previous(['h3', 'div']):
                if prev_node.name == 'h3':
                    set_name = prev_node.text
                    break
                if prev_node.name == 'div':
                    if prev_node.has_attr('class'):
                        if 'scenario-sub-group' in prev_node['class']:
                            set_name = prev_node.text
                            if len(set_name) == 4 and '20' in set_name:
                                set_name = "Gen Con " + set_name
                            break
            set_name_by_scenario_name[scenario_name] = set_name

scenario_dicts = []
scenario_dict_by_scenario_id = {}
scenario_dicts_by_set = {}
for scenario in scenarios:
    scenario_page_path = u'{}/Cards/Scenarios/{}'.format(args.crawl, scenario)
    quest_card_names = []
    normal_card_tuples = []
    easy_card_tuples = []
    nightmare_card_tuples = []
    scenario_name = scenario # we'll try to improve on the hyphenated name
    if os.path.exists(scenario_page_path):
        with codecs.open(scenario_page_path, encoding='utf-8') as scenario_file:
            scenario_parse = BeautifulSoup(scenario_file, 'html.parser')
            for h2 in scenario_parse.find_all('h2'):
                scenario_name = h2.text
            for a in scenario_parse.find_all('a'):
                target = a.get('href')
                if '/Cards/Details' in target:
                    section_heading = 'None'
                    card_id = target.split('/')[-1]
                    h3 = a.find_previous('h3')
                    if h3 is not None:
                        section_heading = h3.text
                    is_quest_card = section_heading == 'Quest Cards'
                    three_sibling_spans = []
                    for sibling in a.find_next_siblings():
                        if sibling.name == 'span':
                            three_sibling_spans.append(sibling)
                    if len(three_sibling_spans) == 3:
                        span1 = three_sibling_spans[0]
                        span2 = three_sibling_spans[1]
                        span3 = three_sibling_spans[2]
                        span1_text = span1.text
                        span2_text = span2.text
                        span3_text = span3.text
                        normal_count = 0
                        easy_count = 0
                        nightmare_count = 0
                        try:
                            normal_count = int(span1_text)
                        except:
                            normal_count = 0
                        try:
                            easy_count = int(span2_text)
                        except:
                            easy_count = 0
                        try:
                            nightmare_count = int(span3_text)
                        except:
                            nightmare_count = 0
                        if is_quest_card:
                            quest_card_names.append(card_id)
                        else:
                            if normal_count > 0:
                                normal_card_tuples.append([card_id, normal_count])
                            if easy_count > 0:
                                easy_card_tuples.append([card_id, easy_count])
                            if nightmare_count > 0:
                                nightmare_card_tuples.append([card_id, nightmare_count])

            scenario_dict = {'name': scenario_name, 'set': set_name_by_scenario_name[scenario], 'quest_cards': quest_card_names, 'encounter_cards': {'normal': normal_card_tuples, 'easy': easy_card_tuples, 'nightmare': nightmare_card_tuples}}
            scenario_dicts.append(scenario_dict)
            scenario_dict_by_scenario_id[scenario] = scenario_dict

# lists all the sets
sets = []

sets_file_path = "{}/LotR/Browse".format(args.crawl)
with codecs.open(sets_file_path, encoding='utf-8') as sets_file:
    sets_parse = BeautifulSoup(sets_file, 'html.parser')
for a in sets_parse.find_all('a'):
  target = a.get('href')
  if "/Cards/Browse" in target:
    sets.append(target.split('/')[-1])

card_names_by_set = {}
card_names = set()

# parse each set's page to get card listing
for set_name in sets:
    card_names_by_set[set_name] = []
    set_page_path = "{}/Cards/Browse/{}".format(args.crawl, set_name)
    with codecs.open(set_page_path, encoding='utf-8') as set_file:
        set_parse = BeautifulSoup(set_file, 'html.parser')
        for a in set_parse.find_all('a'):
          target = a.get('href')
          if "/Cards/Details" in target:
            card_name = target.split('/')[-1]
            card_names_by_set[set_name].append(card_name)
            card_names.add(card_name)

# parse each card's page to get all its metadata
card_dicts = []
card_dicts_by_unique_name = {}
for card_name in card_names:
    card_dict = {}
    card_page_path = "{}/Cards/Details/{}".format(args.crawl, card_name)
    with codecs.open(card_page_path, encoding='utf-8') as card_file:
        card_parse = BeautifulSoup(card_file, 'html.parser')

        # uniqueness
        unique_img = card_parse.findAll("img", {"src" : "/Images/unique-card.png"})
        is_unique = unique_img is not None and len(unique_img) > 0

        # sphere and image URL
        sphere = "None"
        img_urls = []
        encounter_set_icon = "None"

        for img in card_parse.find_all('img'):
            src = img.get('src')
            if '/Images/Leadership' in src:
                sphere = 'Leadership'
            elif '/Images/Tactics' in src:
                sphere = 'Tactics'
            elif '/Images/Spirit' in src:
                sphere = 'Spirit'
            elif '/Images/Lore' in src:
                sphere = 'Lore'
            elif '/Images/Cards' in src and img.parent.name == 'a' and 'EncounterSet' in img.parent['href'] and encounter_set_icon == 'None':
                encounter_set_icon = img['title'] # take only the first of these as the quests have multiple and the first appears to be the "primary"
            elif 'https://s3.amazonaws.com/hallofbeorn-resources/Images/Cards/' in src:
                if src not in img_urls:
                    img_urls.append(src)
                for sibling in img.find_next_siblings():
                    if sibling.name == 'img' and 'https://s3.amazonaws.com/hallofbeorn-resources/Images/Cards' in sibling.get('src'):
                        url = sibling.get('src')
                        if url not in img_urls: # find_next_siblings appears to hit the same img node multiple times
                            img_urls.append(url)

        # type, name
        type = None
        name = card_name
        for div in card_parse.find_all('div'):
            style = div.get('style')
            if style is not None:
                if '20pt' in style:
                    type = div.text
                if '1.75em' in style:
                    name = div.text

        card_dict = {'is_unique': is_unique, 'sphere': sphere, 'img_urls': img_urls, 'type': type, 'name': name, 'unique_name': card_name, 'encounter_icon': encounter_set_icon}

        card_dicts_by_unique_name[card_name] = card_dict
        card_dicts.append(card_dict)

db_dict = {'sets': []}
for set in sets:
    card_names = card_names_by_set[set]
    set_dict = {'name': set, 'cards': []}
    for card_name in card_names:
        card_dict = card_dicts_by_unique_name[card_name]
        set_dict['cards'].append(card_dict)
    db_dict['sets'].append(set_dict)

db_dict['scenarios'] = scenario_dicts



print json.dumps(db_dict)
