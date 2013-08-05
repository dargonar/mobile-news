# -*- coding: utf-8 -*-
#http://www.diarioscastellanos.net/

from bs4 import BeautifulSoup
from bs4.element import Tag
from datetime import datetime, timedelta


def get_datetime(soup_element):  
  months = ['enero', 'febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
  
  soup_element[0].strong.decompose()
  parts  = soup_element[0].text.split()
  # Lunes 05 Agosto 2013
  return datetime(int(parts[3]), months.index(parts[2].lower())+1, int(parts[1]) )

def get_date(hhmm, today_date):
  parts = hhmm.split(':')
  if len(parts)<2:
    parts = [0,0]
  tmp = today_date + timedelta(0,0,0,0,int(parts[1]),int(parts[0]))
  return tmp.strftime("%a, %d %b %Y %H:%M:%S")