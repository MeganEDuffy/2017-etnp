
# Go to repo scripts directory
cd /Users/meganduffy/Documents/git-repos/2017-etnp/scripts

# Use pandas
import pandas as pd 

# Read PEAKS 8.5 de novo output
data = pd.read_csv()

# Keep only peptide column
pep = data[["Peptide"]]

# Write altered dataframe to new csv file
# Used header and index parameters to get rid of 'Peptide' header and the indexing
pep.to_csv()

# Write altered dataframe to new text file 
# Used header and index parameters to get rid of 'Peptide' header and the indexing
pep.to_csv()

# Removes all characters in parentheses and saves as new file

awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }' /file

# Get rid of modifications from all peptides and save as a new file
# Remove '(+15.99)' and '(+57.02)', (+.98) from sequences
sed 's/(+15.99)//g' /file \
| sed 's/(+57.02)//g'\
| sed 's/(+.98)//g'\
> /file

exit()