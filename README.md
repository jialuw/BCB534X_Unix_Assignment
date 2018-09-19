We have 2 files named fang_et_al_genotypes.txt and snp_position.txt.  

# Data Inspection 



## fang\_et\_al\_genotypes  
  

&emsp;&emsp;- **Overview**: how the data is formatted `$ head -n 1  fang_et_al_genotypes.txt`

&emsp;&emsp;- **Column & Lines**: how many numbers of columns and lines   
&emsp;&emsp;&emsp;_COLUMN:_  ``$ awk -F `\t` {print NF; exit} fang_et_al_genotypes.txt ``   
&emsp;&emsp;&emsp;_LINE:_  `$ wc -l fang_et_al_genotypes.txt`

&emsp;&emsp;- **File size**: how large is the file `$ du -h fang_et_al_genotypes.txt `

&emsp;&emsp;- **Inside the file**: open the file to see how the data exactly look like `$ less fang_et_al_genotypes.txt`

&emsp;&emsp;**_Summary_**  
&emsp;&emsp;Up to now, we know that this fang\_et\_al\_genotypes.txt file includes **2782 samples** with **983 SNPs** information coded as **A/T/C/G/?** ( missing data encoded as "?" ). These samples are from different groups ("ZMMIL, ZMMLR, ZMMMR, ZMPBA, etc). The file size is **11M**, which includes **2783 lines** and **986 columns**.  



## snp_position

_(similar with what we do with above)_  
&emsp;&emsp; - **Overview**： how the data is formatted `$ head -n 1 snp_position.txt`  
	
&emsp;&emsp; - **Column & Lines**： how many numbers of columns and lines   
&emsp;&emsp;&emsp;_COLUMN:_  ``$ awk -F `\t` {print NF; exit} snp_position.txt ``   
&emsp;&emsp;&emsp;_LINE:_  `$ wc -l snp_position.txt`  

&emsp;&emsp; - **File size**： how large is the file `$ du -h snp_position.txt`

&emsp;&emsp; - **Inside the file**： open the file to see how the data exactly look like `$ less snp_position_txt`  
	
&emsp;<font color=grey>**_Summary_**</font>  
&emsp;From the above, we know that snp\_position.txt file includes **983 SNPs**' position information (ID, chromosome, etc.). Among these, what we are looking for are in **column 1, 3 and 4 **. These SNPs are in **10 chromosomes** and some are in multiple chromosomes while some also have unknown position.

# Data Processing  

1. SNP information preparation     
 
	`$ cut -f 1, 3, 4 snp_position.txt | (head -n 1 && tail -n +2 | sort -k1, 1 ) > snp_infor.txt`    
				
&emsp;&emsp; - [x] `cut` command is to extract three needed columns from the original file;  
&emsp;&emsp; - [x] `head` and `tail` commands help us keep the header at top when sorting;  
&emsp;&emsp; - [x] `sort` command is to do sorting by the 1st column (SNP_ID).


2. Separate _Maize_ and _Teosinte_ genotypes

	$ grep -E "(ZMMIL|ZMMLR|ZMMMR|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk > (head –n 1 && tail –n +2 | sort –k1,1 )  >maize_transposed_genotype.txt  

&emsp;&emsp; - [x] `grep` command is to print out lines containing "ZMMIL", "ZMMLR" "ZMMMR" and "Group", which are maize samples and the header;  
&emsp;&emsp; - [x] `cut` commands is to remove the 2 columns we don'w need;  
&emsp;&emsp; - [x] `awk` command is to transpose the table so that it has the same data frame with snp_infor.txt;  
&emsp;&emsp; - [x] `head` and `tail` command is to keep the header at top;  
&emsp;&emsp; - [x] `sort` command is to sort by the 1st column (snp  
&emsp;&emsp; - [x] new file saved as "maize_transposed_genotype.txt".  
	     
_(then we will do the same thing to Teosinte)_

	$ grep -E "(ZMMIL|ZMMLR|ZMMMR|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk > (head –n 1 && tail –n +2 | sort –k1,1 )  >maize_transposed_genotype.txt  

1. Combine genotype with SNP position

	`$join -1 1 -2 1 –t ‘\t’ snp_infor.txt maize_transposed_genotype.txt > maize_joined.txt`  
				
	 - [x] `join` command is to combine the two file based on the 1st column of snp_infor.txt and the 1st column of maize_transposed_genotype.txt; 
	 - [x] new file saved as "maize_joined.txt"
	  
1. 
