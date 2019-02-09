# Crawling hallofbeorn.com to make CardWarden boxes

These instructions will allow you to make a cardwarden box with any sets you choose (so long as they fit in the box card limit) and will make a deck for each scenario. The scenario decks have the quest cards and encounter cards together in one deck. You can then take out the quest cards when it's on the table (flip it face-up first).

These tools do not make any player decks, you make those inside the app. The player cards are put at the start of the box and have separators between each set so you can find things somewhat easily to make your player decks. At first I thought it was lame not to make player decks, but since they are more inherently in flux whereas the scenarios are not, I came to like it. You could always extend the scripts to parse player decks, e.g. from json data obtained from the [ringsdb.com API](https://ringsdb.com/api/).

## 0. Requirements

I'm on macOS and needed these pieces I didn't already have:

* [Homebrew](http://brew.sh)
* `brew install wget`
* `brew install imagemagick`
* `pip install beautifulsoup4`

## 1. Crawl the HTML

    `wget --wait=1 --random-wait -r -l 2 -U Mozilla http://hallofbeorn.com/LotR/Browse`

 This command will write its output into a directory named `hallofbeorn.com`. It takes a while, on the order of a coupld hours, because it waits around 1 second between requests so as not to overload the server. But it does not follow links to s3.amazonaws.com to get the images, because I don't know wget well enough to get it to do that, and so we do that as a second step.

## 2. Download all card images, so as to have utf8 characters in the resulting filenames

    `egrep -h -r -o '"http.*?amazonaws.*?"' hallofbeorn.com/Cards/Details/ | sed 's/"//g' | sort -u > cardimages.txt`
    `python urls.py > cardimages_utf8.txt`
    `for i in `cat cardimages_utf8.txt`; do wget -nc --wait 1 --random-wait -p -U Mozilla "$i"; done`

I was unable to get the python module urllib to decode the accented characters (of which there are many) from HTML-encoded forms like "&#123;", and so I hardcoded all the conversions in `urls.py`. My googling led me to believe I was experiencing a urllib bug so I lost patience. Leaving the &-escapes in the URLs was also not an option because wget could not parse its command with an & in the filename.

## 3. Convert all images to CardWarden's PNG format for cards and thumbs

    `python images_to_cardwarden_format.py --imagedir s3.amazonaws.com/hallofbeorn-resources/Images/Cards --outdir beorn_images_cw_format`

For this you need ImageMagick installed, which supplies the command line tool `convert`. The output is a directory "beorn_images_cw_format" with subdirectories `Cards` and `Thumbs` inside of which are subdirectories with names of sets. Note that filenames are reused across sets, e.g. there are a few different `Aragorn.jpg` which are all different. This tripped me up for a while, and I thought I could have all the images flat in a directory together. Nope!

## 4. Scrape the downloaded HTML to json

    `python parse_hallofbeorn_crawl_to_json.py --crawl hallofbeorn.com > hallofbeorn.json`

## 5. Build a CardWarden box of your choosing

    `python make_cardwarden_box.py --db hallofbeorn.json --difficulty normal --outdir box1 --pngdir beorn_images_cw_format --playersets Core-Set,The-Hunt-for-Gollum,Conflict-at-the-Carrock,A-Journey-to-Rhosgobel,The-Hills-of-Emyn-Muil,The-Dead-Marshes,Return-to-Mirkwood,The-Hobbit-Over-Hill-and-Under-Hill,The-Hobbit-On-The-Doorstep --scenariocycles Core-Set,Shadows-of-Mirkwood,The-Hobbit:-Over-Hill-and-Under-Hill,The-Hobbit:-On-the-Doorstep`

The suboptimal thing here is that in the json database player cards have "sets" but scenarios have "cycles". This could stand to be improved.

## 6. Install into CardWarden.

1. Inside `box1` will be four directories: `Cards`, `Thumbs`, `Decks`, and `Meta`. Select all four and zip them. Don't zip their parent directory `box1`. Rename this zip to `Backup.zip`.

2. Connect to your iPad with iTunes and select "File Sharing", then "CardWarden" and if you see any files (such as a folder named `Backup` and a file `Backup.zip`) select them and hit delete to delete them and confirm the deletion.

3. Drag `Backup.zip` that you created in step 1 into the file list. It will take a minute to copy to the iPad.

4. Run CardWarden, select Card Importer, select a box, click "Empty Box" if you need to delete what's in the box at the moment, then click "Restore". This populates the box and you can play!
