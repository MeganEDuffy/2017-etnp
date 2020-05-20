## 2017 ETNP sequence data processing workflow in Jupyter notebooks

### How I processed de novo and databased ID'd peptide data using bash, R, and Unipept 

1. Data exported from PEAKS 8.5 into this repo's data/ directory; used default text-based export file settings with addition of protein `.fasta` file. `dno.txt` files are the 'de novo only' peptides; `peptide.txt` are the database-ID'd peptides from the searches. 

2. Renamed all files to include Keil proteomics running number and PEAKS DB search #, i.e., for sample 375:
  -  `375-peaks3-DB-search-psm.csv`
  -  `375-peaks3-dno.csv`
  -  `375-peaks3-peptide.csv`
  -  `375-peaks3-protein-peptides.csv`
  -  `375-peaks3-protein.csv`
  -  `375-peaks3-protein.fasta`
  
3. Processed the de novo only (`dno.csv`) files in `uwpr-date-dno.ipynb` notebook. 
  -  Used pandas to read in `.csv` and export peptides to new `dnopeps.txt` and `dnopeps.csv` 
  -  Removed modifications from `dnopeps.txt` files and creaded mods only files, `dno-mods.txt`
  -  Used `wc -l` to enumerate mods and total peptides, then calculated the percentage of peptides modified
  -  Made files with mods removed, `dno-nomods.txt`
  
  
4. Processed the PSM peptides (database peptides) (`peptide.csv`) files in `uwpr-date-db.ipynb` notebooks.
  -  Used pandas to read in `.csv` and export peptides to new `dbpeps.txt` and `dbpeps.csv` 
  -  Removed modifications from `dbpeps.txt` files and creaded mods only files, `db-mods.txt`
  -  Used `wc -l` to enumerate mods and total peptides, then calculated the percentage of peptides modified
  -  Made files with mods removed, `db-nomods.txt`
