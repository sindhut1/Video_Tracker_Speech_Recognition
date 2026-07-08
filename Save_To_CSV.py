import csv
import os
import sys

arguments = sys.argv[ 1: ]
headers = [ "STUDENT ID", "VIDEO NUMBER", "COMPLETION STATUS", "DATE" ]
filename = "test_output.csv"
#print(arguments)

if not os.path.exists(filename):
    with open(filename, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(headers)

with open(filename, "a", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(arguments)