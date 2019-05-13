## 2017 ETNP sequence data processing workflow in Jupyter notebooks

### How I processed de novo and databased ID'd peptide data using bash, R, and Unipept 

1. Data exported from PEAKS 8.5 into this repo's data/ directory; used default text-based export file settings with addition of protein `.fasta` file. `dno.txt` files are the 'de novo only' peptides; `peptide.txt` are the database-ID'd peptides from the searches. 

2. Renamed all files to include Keil proteomics running number and PEAKS DB search #, i.e., for sample 375:
  -  `375-peaks3-DB-search-psm.txt`
  -  `375-peaks3-dno.txt`
  -  `375-peaks3-peptide.txt`
  -  `375-peaks3-protein-peptides.txt`
  -  `375-peaks3-protein.txt`
  -  `375-peaks3-protein.fasta`
  
3. Removed modifications from `.txt` files using the 
  
  
  
        
        
