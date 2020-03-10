#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#Richard's html2csv converter
#rbarnes@umn.edu
#

from bs4 import BeautifulSoup
import sys
import csv
import argparse

parser = argparse.ArgumentParser(description='Reads in an HTML and attempts to convert all tables into CSV files.')
parser.add_argument('--delimiter', '-d', action='store', default=',',help="Character with which to separate CSV columns")
parser.add_argument('--quotechar', '-q', action='store', default='"',help="Character within which to nest CSV text")
parser.add_argument('filename',nargs="?",help="HTML file from which to extract tables")
args = parser.parse_args()

if sys.stdin.isatty() and not args.filename:
  parser.print_help()
  sys.exit(-1)
elif not sys.stdin.isatty():
  args.filename = sys.stdin
else:
  args.filename = open(sys.argv[1],'r')

fin  = args.filename.read()
soup = BeautifulSoup(fin,"html.parser")
[s.extract() for s in soup('script')]
tablecount = -1

for table in soup.findAll("table"):
  tablecount += 1
  
  with open(sys.argv[1]+str(tablecount)+'.csv', 'w', newline='') as csvfile:
    fout = csv.writer(csvfile, delimiter=args.delimiter, quotechar=args.quotechar, quoting=csv.QUOTE_MINIMAL)
    for row in table.findAll('tr'):
      cols = row.findAll(['td','th'])
      if cols:
        cols = [str(x.text).strip() for x in cols]
        fout.writerow(cols)
