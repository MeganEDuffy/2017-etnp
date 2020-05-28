### Processing *de novo* and database-ID'd (DB) peptides from the *Prochlorococcus* MED4 Q-Exactive HF dataset 

#### Samples run in duplicate by Rachel Lundeen in the UW MMRC on a Thermo Q-Exactive Plus: 

#### - RAL4_95_MED2_trypsin_1.raw
#### - RAL4_94_MED2_trypsin_2.raw

*Prochlorococcus marinus* strain MED4 (subsp. Pastoris str. CCMP1986; PROMP) Cell pellets from axenic cultures of P. marinus MED4 grown on natural seawater-amended media were extracted using bead-beading to lyse cells. Following a protocol adapted from Qin et al.(2018), proteins underwent reduction of disulfides, alkylation of free cysteine residues, and in-solution protease digestion with trypsin. Samples were analyzed by a Waters ACQUITY M-class (Waters Corporation, Milford MA) ultrahigh pressure liquid chromatography (UPLC) coupled to a Thermo Q Exactive HF Orbitrap high-resolution mass spectrometer (HRMS) equipped with a nano-electrospray ionization (NSI) source. Data were collected using data-dependent acquisition (DDA) on the top 10 ions.

#### Raw data were processed with Peaks Studio v8.5 (Bioinformatics Solutions, Waterloo, Canada), which is based on the original PEAKS de novo algorithm contructed by Bin Ma (Ma et al., 2003). 

Peaks output gives amino acid sequences with confidence scores for the entire sequences, as well as an additional novel positional scoring scheme for portions of the sequences. *De novo* search parameters:

- Enzyme: trypsin
- Missed cleavages: 2
- 15 ppm fragment ion tolerance
- 0.5 Da parent peptide ion tolerance
- Fixed modification: carbamidomethylation on cysteine (+57.02146 Da)
- Variable modification: oxidation of methionine (+15.99491 Da)


Peaks Studio also contains a database search tool, Peaks DB (Zhang et al. 2012), which uses a decoy fusion approach to determine a false discovery rate. Peaks DB search parameters:

- Reference database: *Prochlococcus* MED4 proteome from G. Rocap
- LC-MS/MS contaminant database 'the craptome', included in search space. Downloaded from http://www.thegpm.org/crap/ (Mellacheruvu et al. 2013)
- Enzyme: trypsin
- Missed cleavages: 2
- 15 ppm fragment ion tolerance
- 0.5 Da parent peptide ion tolerance
- Fixed modification: carbamidomethylation on cysteine (+57.02146 Da)
- Variable modification: oxidation of methionine (+15.99491 Da)

#### Peaks Studio results exported with following filters: 

- Unique peptide/protein: 1
- 1% FSR on PSMs

#### Exported files from each sample to this repo (`2017-etnp/data/pro2020/RAL4_95_MED2_trypsin/`):

- `DB-search-psm.csv`      
- `dno.csv`                *de novo* only peptides, lengths, spectral counts, ALC scores, PTMs
- `dno.xml`                 xml readable in the TPP (PeptideProphet, ProteinProphet, StPeter..)
- `peptide.csv`             DB peptides, -logP scores, PTMs
- `peptides.pep.xml`        xml format of above
- `protein-peptides.csv`    peptides ID'd for each protein ID
- `proteins.csv`            protein name, descriptions, coverage, confidence, PTMs
- `proteins.fasta`          list of ID'd proteins in fasta format
- `PSM-ions.csv`

- 