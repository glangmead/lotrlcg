from collections import defaultdict
from xml.etree import cElementTree as ET
import argparse
from difflib import SequenceMatcher
import html
import json
import os
from xxlimited import foo
import unidecode

parser = argparse.ArgumentParser(description='Build a DragnCards First Age file to import.')
parser.add_argument('--deck', type=str, help='a player or scenario deck to convert')
parser.add_argument('--dragncards_db', type=str, help='full cardDB from DragnCards github')
parser.add_argument('--beorn_urls', type=str, help='tsv file with one Beorn URL per line')
parser.add_argument('--out', type=str, help='dragncard txt (secretly json) output')
args = parser.parse_args()

FIRST_AGE_URL_PREFIX="https://s3.amazonaws.com/hallofbeorn-resources/Images/Cards/First-Age"
MANUAL_ASSIGNED_IMAGES = {
    "Beren": "Beren.jpg",
    "Finrod Felagund": "Finrod-Felagund.jpg",
    "Fingon": "Fingon.jpg",
    "Lúthien": "Lúthien.jpg",
    "Eärendil": "Eärendil.jpg",
    "Haleth": "Haleth.jpg",
    "Fingolfin": "Fingolfin.jpg",
    "Húrin": "Húrin.jpg",
    "Ecthelion": "Ecthelion.jpg",
    "Círdan": "Círdan.jpg",
    "Turgon": "Turgon.jpg",
    "Idril Celebrindal": "Idril-Celebrindal.jpg",
    "Melian": "Melian.jpg",
    "Haladin Woodsman": "Haladin-Woodsman.jpg",
    "Eöl": "Eöl.jpg",
    "Mablung": "Mablung.jpg",
    "Orodreth": "Orodreth.jpg",
    "Chieftain of Men": "Chieftain-of-Men.jpg",
    "Thorondor": "Thorondor.jpg",
    "Gondolin Guard": "Gondolin-Guard.jpg",
    "Huan": "Huan.jpg",
    "Aredhel": "Aredhel.jpg",
    "Dwarf of the Blue Mountains": "Dwarf-of-the-Blue-Mountains.jpg",
    "Telchar the Smith": "Telchar-the-Smith.jpg",
    "Green-elf Ranger": "Green-elf-Ranger.jpg",
    "Daeron": "Daeron.jpg",
    "Elwing": "Elwing.jpg",
    "Huor": "Huor.jpg",
    "Bëor": "Bëor.jpg",
    "Hador": "Hador.jpg",
    "Barahir": "Barahir.jpg",
    "Morwen": "Morwen.jpg",
    "Tuor": "Tuor.jpg",
    "Finduilas": "Finduilas.jpg",
    "Azaghâl": "Azaghâl.jpg",
    "High Kingship of the Noldor": "High-Kingship-of-the-Noldor.jpg",
    "Elf-friend": "Elf-friend.jpg",
    "Shadowy Cloak": "Shadowy-Cloak.jpg",
    "Vingilot": "Vingilot.jpg",
    "Harp of Fingon": "Harp-of-Fingon.jpg",
    "Oath of Friendship": "Oath-of-Friendship.jpg",
    "Oath of Vengeance": "Oath-of-Vengeance.jpg",
    "Oath of Silence": "Oath-of-Silence.jpg",
    "Haudh-en-Ndengin": "Haudh-en-Ndengin.jpg",
    "Hidden House": "Hidden-House.jpg",
    "Solitary Outlaw": "Solitary-Outlaw.jpg",
    "Ard-galen Horse": "Ard-galen-Horse.jpg",
    "Ring of Barahir": "Ring-of-Barahir.jpg",
    "Ringil": "Ringil.jpg",
    "Rochallor": "Rochallor.jpg",
    "Blue Shield": "Blue-Shield.jpg",
    "Dragon-helm": "Dragon-helm.jpg",
    "Nimphelos": "Nimphelos.jpg",
    "Aranrúth": "Aranrúth.jpg",
    "Strength of Men": "Strength-of-Men.jpg",
    "Erchamion": "Erchamion.jpg",
    "The Day Has Come!": "The-Day-Has-Come.jpg",
    "Song of Lúthien": "Song-of-Lúthien.jpg",
    "Song of Staying": "Song-of-Staying.jpg",
    "Arts of Felagund": "Arts-of-Felagund.jpg",
    "Passed in Peace": "Passed-in-Peace.jpg",
    "Leaguer": "Leaguer.jpg",
    "Hour of Need": "Hour-of-Need.jpg",
    "A Great Doom": "A-Great-Doom.jpg",
    "Undismayed": "Undismayed.jpg",
    "Feast of Reuniting": "Feast-of-Reuniting.jpg",
    "Banners and Horns": "Banners-and-Horns.jpg",
    "No Better Hope": "No-Better-Hope.jpg",
    "Hold to the Oath": "Hold-to-the-Oath.jpg",
    "Manwë's Pity": "Manwë's-Pity.jpg",
    "Secrets of Craft": "Secrets-of-Craft.jpg",
    "Dreams from Ulmo": "Dreams-from-Ulmo.jpg",
    "Friendship of Ulmo": "Friendship-of-Ulmo.jpg",
    "Strengthen the Watch": "Strengthen-the-Watch.jpg",
    "Secret Toil": "Secret-Toil.jpg",
    "...And Yet A Warning": "And-Yet-A-Warning.jpg",
    "Song of Gladness": "Song-of-Gladness.jpg",
    "Flame Light! Flee Night!": "Flame-Light-Flee-Night.jpg",
    "Day Shall Come Again": "Day-Shall-Come-Again.jpg",
    "Fëanor": "Fëanor.jpg",
    "Thingol": "Thingol.jpg",
    "Túrin Turambar": "Túrin-Turambar.jpg",
    "Celegorm": "Celegorm.jpg",
    "Maglor": "Maglor.jpg",
    "Caranthir": "Caranthir.jpg",
    "Maeglin": "Maeglin.jpg",
    "Maedhros": "Maedhros.jpg",
    "Curufin": "Curufin.jpg",
    "Oath of Fëanor": "Oath of Fëanor.jpg",
    "Nauglamír": "Nauglamír.jpg",
    "Galvorn Armor": "Galvorn-Armor.jpg",
    "Poisoned Javelin": "Poisoned-Javelin.jpg",
    "Gurthang": "Gurthang.jpg",
    "Mormegil": "Mormegil.jpg",
    "Madness of Rage": "Madness-of-Rage.jpg",
    "Fire of Life": "Fire-of-Life.jpg",
    "Defied and Mocked": "Defied-and-Mocked.jpg",
    "Dreadful Death": "Dreadful-Death.jpg",
    "Dark Heart of the Smith": "Dark-Heart-of-the-Smith.jpg",
    "Open Battle": "Open-Battle.jpg",
    "Song of Wizardry": "Song-of-Wizardry.jpg",
    "Weight of Horror": "Weight-of-Horror.jpg",
    "Lord of Werewolves": "Lord-of-Werewolves.jpg",
    "Master of Shadows": "Master-of-Shadows.jpg",
    "No Living Creature": "No-Living-Creature.jpg",
    "Foul Vapour": "Foul-Vapour.jpg",
    "Deep Pit": "Deep-Pit.jpg",
    "Gates of Tol-in-Gaurhoth": "Gates-of-Tol-in-Gaurhoth.jpg",
    "Walls of Stone": "Walls-of-Stone.jpg",
    "High Tower": "High-Tower.jpg",
    "Dark Hills": "Dark-Hills.jpg",
    "Vacant Pit": "Vacant-Pit.jpg",
    "Bridge to the Isle": "Bridge-to-the-Isle.jpg",
    "Eyes in the Dark": "Eyes-in-the-Dark.jpg",
    "Finrod Felagund": "Finrod-Felagund.jpg",
    "Draugluin": "Draugluin.jpg",
    "Wolf-Sauron": "Wolf-Sauron.jpg",
    "Ravenous Werewolf": "Ravenous-Werewolf.jpg",
    "Thuringwethil": "Thuringwethil.jpg",
    "Monstruous Bat": "Monstrous-Bat.jpg",
    "Guard Wolf": "Guard-Wolf.jpg",
    "Hunting Wolf": "Hunting-Wolf.jpg",
    "Crazed Thrall": "Crazed-Thrall.jpg",
    "Devouring Werewolf": "Devouring-Werewolf.jpg",
    "Morgoth": "Morgoth.jpg",
    "Thrall Quarters": "Thrall-Quarters.jpg",
    "Fire-drake": "Fire-drake.jpg",
    "Silmaril": "Silmaril.jpg",
    "Gothmog": "Gothmog.jpg",
    "Troll of Angband": "Troll-of-Angband.jpg",
    "Orc Captain": "Orc-Captain.jpg",
    "Angband Orc": "Angband-Orc.jpg",
    "Balrog of Angband": "Balrog-of-Angband.jpg",
    "Long-worm": "Long-worm.jpg",
    "Carcharoth": "Carcharoth.jpg",
    "Filth and Desolation": "Filth-and-Desolation.jpg",
    "Subterranean Furnace": "Subterranean-Furnace.jpg",
    "Labyrinthine Stairs": "Labyrinthine-Stairs.jpg",
    "Angband Sword": "Angband-Sword.jpg",
    "Echoing Corridor": "Echoing-Corridor.jpg",
    "Trackless Cavern": "Trackless-Cavern.jpg",
    "Tunnels of Shadow": "Tunnels-of-Shadow.jpg",
    "Pits of Angband": "Pits-of-Angband.jpg",
    "Torturer's Dungeon": "Torturer's-Dungeon.jpg",
    "Orc Armory": "Orc-Armory.jpg",
    "Nethermost Hall": "Nethermost-Hall.jpg",
    "Foolish Ruckus": "Foolish-Ruckus.jpg",
    "Evil Lust": "Evil-Lust.jpg",
    "Heroic Diversion": "Heroic-Diversion.jpg",
    "Devouring Spirit": "Devouring-Spirit.jpg",
    "Clumsy Step": "Clumsy-Step.jpg",
    "Dreadful Garments": "Dreadful-Garments.jpg",
    "Element of Surprise": "Element-of-Surprise.jpg",
    "Dark Elf": "Dark-Elf.jpg",
    "Carcharoth the Red Maw": "Carcharoth-the-Red-Maw.jpg",
    "Taur-nu-Fuin": "Taur-nu-Fuin.jpg",
    "Pass of Anach": "Pass-of-Anach.jpg",
    "Dimbar Field": "Dimbar-Field.jpg",
    "Neldoreth Settlement": "Neldoreth-Settlement.jpg",
    "Eaves of Region": "Eaves-of-Region.jpg",
    "Banks of the Esgalduin": "Banks-of-the-Esgalduin.jpg",
    "Iant Iaur": "Iant-Iaur.jpg",
    "Gates of Menegroth": "Gates-of-Menegroth.jpg",
    "Dark Valley": "Dark-Valley.jpg",
    "A Doom Fulfilled": "A-Doom-Fulfilled.jpg",
    "Fled in Fear": "Fled-in-Fear.jpg",
    "Stood Now in Wrath": "Stood-Now-in-Wrath.jpg",
    "Carcaroth the Wolf of Angband": "Carcharoth-the-Wolf-of-Angband.jpg",
    "Flame of Anguish": "Flame-of-Anguish.jpg",
    "Devil's Cunning": "Devil's-Cunning.jpg",
    "Espied from Afar": "Espied-from-Afar.jpg",
    "Evil Days": "Evil-Days.jpg",
    "Brethil Dwelling": "Brethil-Dwelling.jpg",
    "Carcharoth the Devouring Spirit": "Carcharoth-the-Devouring-Spirit.jpg",
    "Carcharoth the Tormented": "Carcharoth-the-Tormented.jpg",
    "Beleg Strongbow": "Beleg-Strongbow.jpg",
    "Upon the Bridge": ["Upon-the-Bridge-1A.jpg", "Upon-the-Bridge-1B.jpg"],
    "The Pits of Sauron": ["The-Pits-of-Sauron-2A.jpg", "The-Pits-of-Sauron-2B.jpg"],
    "Tol-in-Gaurhoth": ["Tol-in-Gaurhoth-3A.jpg", "Tol-in-Gaurhoth-3B.jpg"],
    "Isle of Werewolves rules": ["The-Isle-of-Werewolves-ScenarioA.jpg", "The-Isle-of-Werewolves-ScenarioB.jpg"],
    "Doors of Angband": ["Doors-of-Angband-1A.jpg", "Doors-of-Angband-1B.jpg"],
    "Descent into Darkness": ["Descent-into-Darkness-2A.jpg", "Descent-into-Darkness-2B.jpg"],
    "The Greatest Deed": ["The-Greatest-Deed-3A.jpg", "The-Greatest-Deed-3B.jpg"],
    "To See the Light": ["To-See-the-Light-4A.jpg", "To-See-the-Light-4B.jpg"],
    "Seat of Morgoth rules": ["The-Seat-of-Morgoth-ScenarioA.jpg", "The-Seat-of-Morgoth-ScenarioB.jpg"],
    "Ride Forth in the Morning": ["Ride-Forth-in-the-Morning-1A.jpg", "Ride-Forth-in-the-Morning-1B.jpg"],
    "At Last Upon the Wolf": ["At-Last-Upon-the-Wolf-2A.jpg", "At-Last-Upon-the-Wolf-2B.jpg"],
    "Ruin Upon the World": ["Ruin-Upon-the-World-3A.jpg", "Ruin-Upon-the-World-3B.jpg"],
    "Hunting of the Wolf rules": ["Hunting-of-the-Wolf-ScenarioA.jpg", "Hunting-of-the-Wolf-ScenarioB.jpg"],
}

# dragn_db has keys that are card UUIDs
with open(args.dragncards_db, encoding='utf-8') as db:
    dragn_db=json.load(db)

# read a set of beorn URLs
beorn_urls = set()
beorn_url_by_ascii_name = {}
beorn_url_by_utf_name = {}
with open(args.beorn_urls, encoding='utf-8') as beorn:
    for line in beorn:
        url = line.rstrip()
        utf_name = html.unescape(url.split('/')[-1]).replace('.jpg', '')
        #print(utf_name)
        ascii_name = utf_name.replace('-', ' ')
        beorn_urls.add(url)
        beorn_url_by_ascii_name[ascii_name] = url
        beorn_url_by_utf_name[utf_name] = url

# read the dragncards database
dragncards_d = {}
used_beorn_images = set()
for k in dragn_db.keys():
    card_d = dragn_db[k]
    cardid = card_d["cardid"]
    cardpackname = card_d["cardpackname"]
    sides = card_d["sides"]

    cardname = sides["A"]["name"]
    cardprintname = sides["A"]["printname"]

    dragncards_d[cardid] = card_d
    if cardprintname in MANUAL_ASSIGNED_IMAGES:
        img_filename = MANUAL_ASSIGNED_IMAGES[cardprintname]
        if type(img_filename) == type([]):
            sides["A"]["customimgurl"] = f"{FIRST_AGE_URL_PREFIX}/{img_filename[0]}"
            sides["B"]["customimgurl"] = f"{FIRST_AGE_URL_PREFIX}/{img_filename[1]}"
        elif type(img_filename) == type(""):
            sides["A"]["customimgurl"] = f"{FIRST_AGE_URL_PREFIX}/{img_filename}"


def o8d_to_dict(path):
    with open(args.deck, encoding='utf-8') as deck_data:
        deck_str = deck_data.read()
        deck_dict = xml2dict_recursive(ET.XML(deck_str))
        return deck_dict
    return None

def xml2dict_recursive(t):    
    d = {t.tag: {} if t.attrib else None}
    children = list(t)
    if children:
        dd = defaultdict(list)
        for dc in map(xml2dict_recursive, children):
            for k, v in dc.items():
                dd[k].append(v)
        d = {t.tag: {k: v[0] if len(v) == 1 else v
                     for k, v in dd.items()}}
    if t.attrib:
        d[t.tag].update(('@' + k, v)
                        for k, v in t.attrib.items())
    if t.text:
        text = t.text.strip()
        if children or t.attrib:
            if text:
              d[t.tag]['#text'] = text
        else:
            d[t.tag] = text
    return d

# data to put in cardRow.deckgroupid, cardRow.discardgroupid
OCT_TO_DRAGN_STATIC_GROUPS = {
    "Quest": ["sharedQuestDeck", "sharedQuestDiscard"],
    "Encounter": ["sharedEncounterDeck", "sharedEncounterDiscard"],
    "Setup": ["sharedEncounterDeck", "sharedEncounterDiscard"],
    "Hero": ["player1Deck", "player1Discard"],
    "Ally": ["player1Deck", "player1Discard"],
    "Attachment": ["player1Deck", "player1Discard"],
    "Event": ["player1Deck", "player1Discard"],
    "Special": ["sharedQuestDeck", "sharedQuestDiscard"],
}
# data to put in the card's root.groupId (sibling of "cardRow" and "quantity")
OCT_TO_DRAGN_STARTING_GROUPS = {
    "Quest": "sharedQuestDeck",
    "Encounter": "sharedEncounterDeck",
    "Setup": "sharedSetAside",
    "Hero": "player1Play1",
    "Ally": "player1Deck",
    "Attachment": "player1Deck",
    "Event": "player1Deck",
    "Special": "sharedQuestDeck",
}
# dragncards has the wrong card back for some stuff
OCT_TO_DRAGN_CARD_BACK = {
    "Encounter": "encounter",
    "Hero": "player",
    "Ally": "player",
    "Attachment": "player",
    "Event": "player",
}

# read deck into deck_data_by_id
deck_dict = o8d_to_dict(args.deck)
deck_data_by_id = {}
for section_dict in deck_dict.get("deck", {}).get("section", []):
    secname = section_dict["@name"]
    for card_dict in section_dict.get("card", []):
        card_qty = int(card_dict.get("@qty", 1))
        card_id = card_dict.get("@id", "")
        card_text = card_dict.get("#text", "")
        deck_data_by_id[card_id] = {
            "quantity": card_qty,
            "deckgroupid": OCT_TO_DRAGN_STATIC_GROUPS[secname][0],
            "discardgroupid": OCT_TO_DRAGN_STATIC_GROUPS[secname][1],
            "groupId": OCT_TO_DRAGN_STARTING_GROUPS[secname],
        }
        if secname in OCT_TO_DRAGN_CARD_BACK:
            deck_data_by_id[card_id]["back"] = OCT_TO_DRAGN_CARD_BACK[secname]

dicts = []
for card_id in deck_data_by_id.keys():
    deck_card_data = deck_data_by_id[card_id]
    dragn_data = dragncards_d[card_id]
    dragn_data["deckgroupid"] = deck_card_data["deckgroupid"]
    dragn_data["discardgroupid"] = deck_card_data["discardgroupid"]
    if "back" in deck_card_data:
        dragn_data["sides"]["B"]["name"] = deck_card_data["back"]
        dragn_data["sides"]["B"]["printname"] = deck_card_data["back"]
    dicts.append({
        "cardRow": dragn_data,
        "quantity": deck_card_data["quantity"],
        "groupId": deck_card_data["groupId"],
    })

# test export
# dicts = []
# for k in dragncards_d.keys():
#     cardrow_d = {"deckgroupid": "player1Deck", "discardgroupid": "player1Discard"}
#     for card_k in dragncards_d[k].keys():
#         cardrow_d[card_k] = dragncards_d[k][card_k]
#     dicts.append({"cardRow": cardrow_d, "quantity": 1, "groupId": "player1Deck"})

if os.path.exists(args.out):
    os.remove(args.out)
with open(args.out, 'w', encoding='utf-8') as out:
    json.dump(dicts, out, indent=2)
    