from bs4 import BeautifulSoup
import request

r = request.get('https://reddit.com')
soup = BeautifulSoup(r.text)

print(soup.prettify())
