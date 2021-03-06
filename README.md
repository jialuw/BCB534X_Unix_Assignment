# UNIX_Assignment  

***
  
#### Files needed:
- [x] fang_et_al_genotypes.txt
- [x] snp_position.txt
- [x] transpose.txt
  
#### Work flow:
- [x] Data inspection  
- [x] Data processing
- [x] Document classfying 
  
***  
# _Data Inspection_    
## fang\_et\_al\_genotypes.txt  
  
- **Overview**: how the data is formatted `$ head -n 1  fang_et_al_genotypes.txt`

- **Column & Lines**: how many numbers of columns and lines   
_COLUMN:_  ``$ awk -F `\t` {print NF; exit} fang_et_al_genotypes.txt ``   
_LINE:_  `$ wc -l fang_et_al_genotypes.txt`

- **File size**: how large is the file `$ du -h fang_et_al_genotypes.txt `

- **Inside the file**: open the file to see how the data exactly look like `$ less fang_et_al_genotypes.txt`

**_Summary_**  
Up to now, we know that this `fang\_et\_al\_genotypes.txt` file includes **2782 samples** with **983 SNPs** information coded as **A/T/C/G/?** ( missing data encoded as "?" ). These samples are from different groups ("ZMMIL, ZMMLR, ZMMMR, ZMPBA, etc). The file size is **11M**, which includes **2783 lines** and **986 columns**.  



## snp_position.txt

_(similar with what we do with above)_  
 
- **Overview**: how the data is formatted `$ head -n 1 snp_position.txt`  
	
- **Columns & Lines**: how many numbers of columns and lines   
_COLUMN:_  ``$ awk -F `\t` {print NF; exit} snp_position.txt ``   
_LINE:_  `$ wc -l snp_position.txt`  

- **File size**: how large is the file `$ du -h snp_position.txt`

- **Inside the file**: open the file to see how the data exactly look like `$ less snp_position_txt`  
	
**_Summary_**  
From the above, we know that `snp\_position.txt` file includes **983 SNPs**' position information (ID, chromosome, etc.). Among these, what we are looking for are in **column 1, 3 and 4 **. These SNPs are in **10 chromosomes**; some are in **multiple chromosomes** or **multiple positions** in a specific chromosome; some have **unknown** position.

# _Data Processing_   

## 1. Extract SNP information   
	$ cut -f 1,3,4 snp_position.txt | sort -k1,1 > snp_infor.txt  
  
 -  `cut` command is to extract three needed columns from the original file;     
 -  `sort` command is to do sorting by the 1st column (SNP_ID).    
   
## 2. Separate _Maize_ and _Teosinte_ genotypes   
	$ grep -E "(ZMMIL|ZMMLR|ZMMMR|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk  > maize_genotype.txt  
	$ sed 's/Sample_ID/SNP_ID/' maize_genotype.txt | sort –k1,1 > maize_sgenotype.txt 
	$ grep -E "(ZMPBA|ZMPIL|ZMPJA|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk > teosinte_genotype.txt  
	$ sed 's/Sample_ID/SNP_ID/' teosinte_genotype.txt | sort –k1,1 > teosinte_sgenotype.txt
 - `grep` command is to print out lines containing "ZMMIL", "ZMMLR" "ZMMMR" and "Group" ("ZMPBA", "ZMPIL" "ZMPJA" and "Group" for teosinte), which are maize samples and the header;
 - `cut` commands is to remove the 2 columns we don't need;
 - `awk` command is to transpose the table so that it has the same data frame with snp_infor.txt and we can join them later;
 - `sed` command is change the header in genotype file to the same with SNP file, so that we can join them later;
 - `sort` command is to sort by the 1st column;
 - new files saved as `maize_sgenotype.txt` and `teosinte_sgenotype.txt`.  

## 3. Combine genotype with SNP position      
	$join -1 1 -2 1 –t $'\t' snp_infor.txt maize_sgenotype.txt > maize_joint.txt  
	$join -1 1 -2 1 –t $'\t' snp_infor.txt teosinte_sgenotype.txt > teosinte_joint.txt				
 - `join` command is to combine the two file based on the 1st column of `snp_infor.txt` and the 1st column of `maize_transposed_genotype.txt`; 
 - new file saved as `maize_joint.txt` . 
 
## 4. Separate SNPs based on Chromosome   
	$ for i in {1..10} ; do (awk '$1 ~ /SNP/' maize_joint.txt && awk '$2 == '$i'&& $3 != "multiple"' maize_joint.txt) > maize_chr$i.txt ; done
	$ (awk '$1 ~ /SNP/' maize_joint.txt && awk '$3 == "unknown"' maize_joint.txt )> maize_unknown.txt
	$ (awk '$1 ~ /SNP/' maize_joint.txt && awk '$2 == "multiple" || $3 == "multiple"' maize_joint.txt )> maize_multiple.txt
	$ for i in {1..10} ; do (awk '$1 ~ /SNP/' teosinte_joint.txt && awk '$2 == '$i' && $3 != "multiple"' teosinte_joint.txt) > teosinte_chr$i.txt ; done
	$ (awk '$1 ~ /SNP/' teosinte_joint.txt && awk '$3 == "unknown"' teosinte_joint.txt )> teosinte_unknown.txt
	$ (awk '$1 ~ /SNP/' teosinte_joint.txt && awk '$2 == "multiple" || $3 == "multiple" ' teosinte_joint.txt) > teosinte_multiple.txt
 - `for` command is used to do the loop for 10 chromosomes;
 - `awk` command is used to first print out header and then print out the records which feature pattern that field2 is the same with value of i;
 - new file saved as `maize_chr$i.txt` and `teosinte_Chr$i.txt`, in which i is the number of chromosome.

## 5. Sort SNPs based on position 

	$ for i in {1..10}; do (head -n 1 maize_chr$i.txt && tail -n +2 maize_chr$i.txt | sort -k3,3n )> incr_maize_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 maize_chr$i.txt && tail -n +2 maize_chr$i.txt | sort -k3r,3n ) | sed 's/?/-/g' > decr_maize_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 teosinte_chr$i.txt && tail -n +2 teosinte_chr$i.txt | sort -k3,3n )> incr_teosinte_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 teosinte_chr$i.txt && tail -n +2 teosinte_chr$i.txt | sort -k3r,3n ) | sed 's/?/-/g' > decr_teosinte_chr$i.txt ; done
 - `for` command is used to do the loop for 10 files;
 - `head` and `tail` command are used to keep the header at top and then do the sorting on the other lines;
 - `sort` command is the key command here. We do the sorting based on the 3rd column, which shows the position of SNP. `-k3` means the result will be listed increasingly and `-k3r` means the reverse. `3n` means they are treated as numeric. 
 - `sed` command is used to switch the "?", which is encoded to be missing data, to "-";
 - new files are saves as `incr_maize_chr$i.txt` / `incr_teosinte_chr$i.txt` if their position is listed increasingly; `decr_maize_chr$i.txt` / `decr_teosinte_chr$i.txt` if their position is listed decreasingly.
# _Document classifying_  
  

	$ mkdir maize teosinte process_file
	$ mv decr_maize* incr_maize* maize_m* maize_u* ./maize
	$ mv decr_teosinte* incr_teosinte* teosinte_m* teosinte_u* ./teosinte
	$ mv * ./process_file   
 - `mkdir` command is to make sub-directories under this directory;
 - `mv` commands are to move files to different directories;
 - Here we moved 12 maize-related files to `./maize` directory; 12 teosinte-related files to `./teosinte` directory; the other files generated during the above process and also the original 3 files are moved to `./process\_file`.
 
Then we want to check if the files are correctly generated. `cd` command helps us go into different repositories.   
Within `./maize` and `./teosinte`, do `wc -l *` respectively to check how many lines each file contains;
Within `./process_file`:  
do `cut -f 3 snp_infor.txt | sort -k1,1 | uniq -c ` to check the SNP number in each chromosome;
do ` awk '$3 =="multiple"' snp_infor.txt | cut -f 2-3 | sort -k1,1 | uniq -c` to check in which chromosome there are SNPs with multiple positions.
  
#### Compare the result and list them below:
( _only increasing-position files are shown here_ )   


	  


 | Chr. | $uniq -c (Chr.)| $wc -l (files) | "multiple" in $Position |file_name1 | file_name2 |
 |:-----: |:-----:|:-----:|:-----:|:-----:|:-----:|
 | 1 | 155 | 156 | 0 |incr_maize_chr1.txt|  incr_teosinte_chr1.txt |
 | 2 | 127 | 127 | 1 |incr_maize_chr2.txt|  incr_teosinte_chr2.txt |
 | 3 | 107 | 108 | 0 |incr_maize_chr3.txt|  incr_teosinte_chr3.txt |
 | 4 | 91 | 89 | 3 |incr_maize_chr4.txt|  incr_teosinte_chr4.txt |
 | 5 | 122 | 123 | 0 |incr_maize_chr5.txt|  incr_teosinte_chr5.txt |
 | 6 | 76 | 74 | 3 |incr_maize_chr6.txt|  incr_teosinte_chr6.txt |
 | 7 |  97| 97 | 1 |incr_maize_chr7.txt|  incr_teosinte_chr7.txt |
 | 8 | 62 | 63 | 0 |incr_maize_chr8.txt|  incr_teosinte_chr8.txt |
 | 9 | 60 | 58 | 3 |incr_maize_chr9.txt|  incr_teosinte_chr9.txt |
 | 10 | 53 | 54 | 0 |incr_maize_chr10.txt|  incr_teosinte_chr10.txt |
 | multiple | 6 | 18 | (11) |maize_multiple.txt| teosinte_multiple.txt |
 | unknown | 27 | 28 | 0 |maize_unknown.txt| teosinte_unknown.txt |   
 

To check if we have correct result, we use this rule : `$3 = $2 - $4 + 1`, in which `$` means column.  
`$2` shows how many SNPs in corresponding Chromosome;  
`$3` shows how many SNPs in corresponding files;  
`$4` shows how many SNPs in the corresponding Chromosome which is coded "multiple" in position;  
`1` means the header line of files. 


#### :raising_hand: _All 44 files are ready now!!!_