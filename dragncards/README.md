# First Age!

Check out [the official site about these First Age cards](https://talesfromthecards.wordpress.com/first-age/)

This github repo contains text files you can load into [DragnCards](https://dragncards.com) to play First Age scenarios, with First Age player decks!

To play, download one scenario and one player deck from the `dragn_txt` directory, then go to dragncards.com and log in, and use Menu > Load > Load custom cards (.txt) twice to load each of them in. Then play!

The site also contains the python script I used to generate these text files, with some notes below.

# To generate similar DragnCards sets of your own

To make a .txt you run something like:

```
python deck_to_dragncards.py --dragncards_db dragn_cardDB.json --deck threes-company.o8d --out threes-company.mydragn.txt
```

To get `dragn_cardDB.json`, Download the [master json card database](https://raw.githubusercontent.com/seastan/DragnCards/development/frontend/src/cardDB/cardDB.json)

To obtain a player deck in o8d format, I hand-edited an o8d using these informal listings:

  * https://talesfromthecards.wordpress.com/2014/07/01/first-age-deck-threes-company/
  * https://talesfromthecards.wordpress.com/2014/07/21/first-age-strength-of-will/
  * https://talesfromthecards.wordpress.com/2015/03/26/first-age-deck-scrying-and-smashing/
  * https://talesfromthecards.wordpress.com/2016/03/31/first-age-mustering-the-edain/
  * https://talesfromthecards.wordpress.com/2014/07/01/first-age-deck-threes-company/

The encounter .o8d decks come from [the OCTGN plugin repo](https://github.com/seastan/Lord-of-the-Rings/tree/master/o8g/Decks/Custom).

The output will only contain images for First Age cards, on top of whatever's in the live DragnCards built-in database. I obtained the First Age image URLs with the crawling technique below, and then hard-coded those into the script.

# Crawling Hall of Beorn for image URLs

There are cards that have images on [Hall of Beorn](https://hallofbeorn.com) that are not already in DragnCards. In that case, you can use some simple scraping logic to get S3 URLs to those images.

First crawl hallofbeorn.com (politely) with a command like

```
wget -N --wait=1 --random-wait -r -l 1 -U Mozilla http://hallofbeorn.com/LotR/Products/First-Age
```

and then grep out all the image URLs with something like

```
ack -hor 'https?://s3[^"]+' hallofbeorn.com | sort -u | ack "/First-Age"
```
