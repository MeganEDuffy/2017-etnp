## Processing *de novo* and database-ID'd (DB) peptides from the *Prochlorococcus* MED4 Q-Exactive HF dataset 

### Samples run in technical duplicate by Rachel Lundeen in the UW MMRC on a Thermo Q-Exactive Plus, February 2016: 

#### - 022016_RAL4_95_MED2_trypsin_1.raw
#### - 022016_RAL4_94_MED2_trypsin_2.raw

*Prochlorococcus marinus* strain MED4 (subsp. Pastoris str. CCMP1986; PROMP) Cell pellets from axenic cultures of P. marinus MED4 grown on natural seawater-amended media were extracted using bead-beading to lyse cells. Following a protocol adapted from Qin et al.(2018), proteins underwent reduction of disulfides, alkylation of free cysteine residues, and in-solution protease digestion with trypsin. Samples were analyzed by a Waters ACQUITY M-class (Waters Corporation, Milford MA) ultrahigh pressure liquid chromatography (UPLC) coupled to a Thermo Q Exactive HF Orbitrap high-resolution mass spectrometer (HRMS) equipped with a nano-electrospray ionization (NSI) source. Data were collected using data-dependent acquisition (DDA) on the top 10 ions.

Run parameters:

- Ion source: ESI(nano-spray) 
- Fragmentation mode: CID, CAD(y and b ions) 
- MS scan mode: FT-ICR/Orbitrap 
- MS/MS scan mode: linear ion trap

### Raw data were processed with Peaks to get peptide sequences by 2 means (*de novo* and database searching)

#### PEAKS Studio v8.5 (Bioinformatics Solutions, Waterloo, Canada) is based on the original PEAKS de novo algorithm contructed by Bin Ma ([Ma et al., 2003](https://pubmed.ncbi.nlm.nih.gov/14558135/)). 

Peaks output gives amino acid sequences with confidence scores for the entire sequences, as well as an additional novel positional scoring scheme for portions of the sequences. *De novo* search parameters:

- Enzyme: trypsin
- Missed cleavages: 2
- 15 ppm fragment ion tolerance
- 0.5 Da parent peptide ion tolerance
- Fixed modification: carbamidomethylation on cysteine (+57.02146 Da)
- Variable modification: oxidation of methionine (+15.99491 Da)


Peaks Studio also contains a database search tool, Peaks DB ([Zhang et al. 2012](https://pubmed.ncbi.nlm.nih.gov/22186715/)), which uses a decoy fusion approach to determine a false discovery rate. Peaks DB search parameters:

- Reference database: *Prochlococcus* MED4 proteome from G. Rocap (ME4aa_GR_hi3)
- LC-MS/MS contaminant database 'the craptome', included in search space. Downloaded from http://www.thegpm.org/crap/ ([Mellacheruvu et al. 2013](https://www-nature-com.offcampus.lib.washington.edu/articles/nmeth.2557)
- Enzyme: trypsin
- Max. missed cleavages: 2
- Parent mass error tolerance: 15.0 ppm
- Fragment mass error tolerance: 0.5 Da
- Mass search type: monoisotopic
- Fixed modification: carbamidomethylation on cysteine (+57.02146 Da)
- Variable modification: oxidation of methionine (+15.99491 Da)
- Max. variable PTM Per Peptide: 2
- Searched entry: 1834
- Enabled merge options: no merge

#### Peaks Studio results exported with following filters: 

- Unique peptide/protein: 1
- 1% FSR on PSMs
- ALC > 50%

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
- `all-dn-candidates.csv`   all de novo candidates (all ALCs), mass, m/z, z, RT, tag length
- `dn-peptides.csv`         all (DNO a subset) de novo peptide (export both >50 and >80 ALC files)
- `dn-peptides.xml`         same as above but XML format
- `peptide-features`        all peptide features with peak areas, m/z, z, and de novo candidate seqs.

### *De novo* peptides aligned to *Prochlorococcus* proteome using PepExplorer

#### This alignment tool is part of the [Pattern Lab for Proteomics](http://patternlabforproteomics.org/) environment, see [Leprevost et al., 2014](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4159663/). PepExplorer can read the output of various widely adopted *de novo* sequencing tools (including Peaks 8.5) and converges to a list of proteins with a global false-discovery rate. It employs a radial basis function neural network that considers precursor charge states, *de novo* sequencing scores, peptide lengths, and alignment scores to select similar protein candidates from a target-decoy database, itseld obtained from the given search database (in our case, the same used for Peaks DB and TPP Comet searches). 

PepExplorer alignment parameters:

- Minimum alignment score: 0.75
- Decoy search type: reverse
- Minimum peptide length: 6
- Minimum *de novo* score: 0 (we input >50 ALC)
- Input type: Peaks 8.0/8.5
- L/I(leucine/isoleucine) equating

Alignment results are then saved in PepExplorer Result format (