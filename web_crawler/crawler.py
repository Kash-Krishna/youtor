import sys, os, time
from kat import search_kat
from extraTorrents import search_extra_t

reload(sys)
sys.setdefaultencoding('utf-8')

#magical header found on stack overflow 
hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11', 
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1, utf-8; q=0.7,*q=0.3',
       'Accept-Encoding': 'gzip',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection':'keep-alive'
      }

if __name__ == "__main__":
    argc = len(sys.argv)

    if argc <= 1:
        print "NOT ENOUGH ARGUMENTS"
        sys.exit()
    
    #taking in command line arguments
    #client.py source query
    #query is optional, if query is empty, search source for latest
    source = sys.argv[1]
    print "Source: " + source

    if argc <= 2:
        print "No query provided, searching source for latest torrents"
        query = ""
    else:
        query = sys.argv[2]
    print "query: " + query
    
    if source == "kat.cr" or source == "kat" or sourcec == "kickass":
        search_kat(query,hdr)
    elif source == "extratorrents":
        search_extra_t(query,hdr)
    else:
        print "INVALID SOURCE"

