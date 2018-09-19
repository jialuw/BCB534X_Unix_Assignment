We have 2 files named fang_et_al_genotypes.txt and snp_position.txt.  

# Data Inspection 



## fang\_et\_al\_genotypes  
  

	- **Overview** - how the data is formatted `$ head -n 1  fang_et_al_genotypes.txt`

	- **Column & Lines** - how many numbers of columns and lines   
	_COLUMN:_  ``$ awk -F `\t` {print NF; exit} fang_et_al_genotypes.txt ``   
    _LINE:_  `$ wc -l fang_et_al_genotypes.txt`

	- **File size** - how large is the file `$ du -h fang_et_al_genotypes.txt `

	- **Inside the file** - open the file to see how the data exactly look like `$ less fang_et_al_genotypes.txt`

**_Summary_**  

&emsp;&emsp;Up to now, we know that this fang\_et\_al\_genotypes.txt file includes **2782 samples** with **983 SNPs** information coded as **A/T/C/G/?** ( missing data encoded as "?" ). These samples are from different groups ("ZMMIL, ZMMLR, ZMMMR, ZMPBA, etc). The file size is **11M**, which includes **2783 lines** and **986 columns**.  



## snp_position

	_(similar with what we do with above)_  

	- ** Overview ** - how the data is formatted `$ head -n 1 snp_position.txt`  
	
	- **Column & Lines** - how many numbers of columns and lines   
	_COLUMN:_  ``$ awk -F `\t` {print NF; exit} snp_position.txt ``   
    _LINE:_  `$ wc -l snp_position.txt`

	- **File size** - how large is the file `$ du -h snp_position.txt`

	- **Inside the file** - open the file to see how the data exactly look like `$ less snp_position_txt`  
	
<font color=grey>**_Summary_**</font>  
&emsp;&emsp;From the above, we know that snp\_position.txt file includes **983 SNPs**' position information (ID, chromosome, etc.). Among these, what we are looking for are in **column 1, 3 and 4 **. These SNPs are in **10 chromosomes** and some are in multiple chromosomes while some also have unknown position.

# Data Processing  

1. SNP information preparation     
 
	`$ cut -f 1, 3, 4 snp_position.txt | (head -n 1 && tail -n +2 | sort -k1, 1 ) > snp_infor.txt`    
				
	 - [x] Since we only need SNP_ID, Chromosome and posion columns, we use `cut` command here to extract these three columns from the original file. 
	 - [x] `head` and `tail` commands help us keep the header at top when sorting.  
