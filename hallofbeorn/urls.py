# -*- coding: utf-8 -*-
import codecs

with open('cardimages.txt') as urls:
    with codecs.open('cardimages_utf8.txt', 'w', encoding='utf-8') as outfile:
        for line in urls:
            line = line.replace("&#201;", u"É")
            line = line.replace("&#211;", u"Ó")
            line = line.replace("&#225;", u"á")
            line = line.replace("&#226;", u"â")
            line = line.replace("&#228;", u"ä")
            line = line.replace("&#233;", u"é")
            line = line.replace("&#235;", u"ë")
            line = line.replace("&#237;", u"í")
            line = line.replace("&#238;", u"î")
            line = line.replace("&#243;", u"ó")
            line = line.replace("&#246;", u"ö")
            line = line.replace("&#250;", u"ú")
            line = line.replace("&#251;", u"û")
            line = line.replace("&#39;", u"'")
            outfile.write(line)
