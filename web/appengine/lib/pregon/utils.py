# -*- coding: utf-8 -*-
from datetime import datetime, timedelta

def get_today_date(soup):
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  tmp = soup.select('div.clima div')

  # 31 de Julio de 2013
  parts = tmp[len(tmp)-1].text.split()
  while 'de' in parts: parts.remove('de')
  if len(parts) > 3: parts = parts[-3:]

  inx = months.index(parts[1].lower())
  return datetime(int(parts[2]), inx+1, int(parts[0]) )

def get_date(today_date, hhmm):
  parts = hhmm.split(':')
  tmp = today_date + timedelta(0,0,0,0,int(parts[1]),int(parts[0]))
  return tmp.strftime("%a, %d %b %Y %H:%M:%S")

def get_one(soup, path):
  s = soup.select(path)
  if len(s):
    return s[0]

  return None
