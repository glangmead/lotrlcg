# First Age!

Check out [the official site about these First Age cards](https://talesfromthecards.wordpress.com/first-age/)

This github repo contains text files you can load into [DragnCards](https://dragncards.com) to play First Age scenarios, with First Age player decks!

To play, download one scenario and one player deck from the `dragn_txt` directory, then go to dragncards.com and log in, and use Menu > Load > Load custom cards (.txt) twice to load each of them in. Then play!

The site also contains the python script I used to generate these text files, with some notes below.

# To generate similar DragnCards sets of your own

1. Download the [master json card database](https://raw.githubusercontent.com/seastan/DragnCards/development/frontend/src/cardDB/cardDB.json)

2. Obtain a player deck in o8d format, perhaps by hand-editing an o8d like I did from these:

  * https://talesfromthecards.wordpress.com/2014/07/01/first-age-deck-threes-company/
  * https://talesfromthecards.wordpress.com/2014/07/21/first-age-strength-of-will/
  * https://talesfromthecards.wordpress.com/2015/03/26/first-age-deck-scrying-and-smashing/
  * https://talesfromthecards.wordpress.com/2016/03/31/first-age-mustering-the-edain/
  * https://talesfromthecards.wordpress.com/2014/07/01/first-age-deck-threes-company/

Or obtain an encounter deck like these that I found:

# Obtaining image URLs from Hall of Beorn

There are cards that have images on [Hall of Beorn](https://hallofbeorn.com) that are not already in DragnCards. In that case, you can use some simple scraping logic to get S3 URLs to those images.

1. Crawl hallofbeorn.com (politely) with a command like

```
wget -N --wait=1 --random-wait -r -l 1 -U Mozilla http://hallofbeorn.com/LotR/Products/First-Age
```

and then grep out all the image URLs with something like

```
ack -hor 'https?://s3[^"]+' hallofbeorn.com | sort -u | ack "/First-Age"
```
