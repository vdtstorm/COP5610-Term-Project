# -*- coding: utf-8 -*-
"""File Dependencies

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/15xpLp08gwBQqmfW4kPEc77Pr8YOi2cxx
"""

import sys 
import matplotlib.pyplot as plt
import numpy as mp
from collections import defaultdict

"""# Section 1: Importing from the github repository."""

!git clone https://github.com/FamousStephens/COP5610-Term-Project.git

file_source = "COP5610-Term-Project/out.dot"
dependency_file = open(file_source, "r")

"""# Section 2: Creating the dictionary

To calculate the frequency of file dependency occurances, a dictionary will be used. The key value is the hash of a file, the value is the frequency of the hash.
"""

i = 0
leng = 0
d = {}
#d = defaultdict(list) #creating empty dictionary 
d['File'] = [] # adding a list for files
with open(file_source,"r") as dep_file:
  lines = dep_file.readlines()
  for line in lines:
      if line.find('{') != -1 or line.find('digraph') != -1 or line.find('}') != -1: # Filtering to find file
        continue
      elif line.find('[') != -1 or line.find('->') != -1 or line.find(']') != -1: # Filtering to find file
        continue
      else: # this will store the dependency files in a dictionary list
        d['File'].append(line.strip(';\n')) # removing newline from file entry
        
dep_file.close()
#print(d)
d['Count'] = [] * len(d['File']) # giving the count the size of the number of files
c = 0
i = 0
# Iterate through file to get the count of how many times that the file has occured
for n in d['File']:
  with open(file_source,"r") as dep_file:
    lines = dep_file.readlines()
    for line in lines:
      if line.find('-> ' + n) != -1 and line.find(n) != -1:
        c+=1
    dep_file.close()
  d['Count'].append(c)
  c = 0
  i+=1
print(d)