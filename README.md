 

# _Data Inspection_    
## fang\_et\_al\_genotypes.txt  
  
- **Overview**: how the data is formatted `$ head -n 1  fang_et_al_genotypes.txt`

- **Column & Lines**: how many numbers of columns and lines   
_COLUMN:_  ``$ awk -F `\t` {print NF; exit} fang_et_al_genotypes.txt ``   
_LINE:_  `$ wc -l fang_et_al_genotypes.txt`

- **File size**: how large is the file `$ du -h fang_et_al_genotypes.txt `

- **Inside the file**: open the file to see how the data exactly look like `$ less fang_et_al_genotypes.txt`

**_Summary_**  
Up to now, we know that this fang\_et\_al\_genotypes.txt file includes **2782 samples** with **983 SNPs** information coded as **A/T/C/G/?** ( missing data encoded as "?" ). These samples are from different groups ("ZMMIL, ZMMLR, ZMMMR, ZMPBA, etc). The file size is **11M**, which includes **2783 lines** and **986 columns**.  



## snp_position.txt

_(similar with what we do with above)_  
 
- **Overview**： how the data is formatted `$ head -n 1 snp_position.txt`  
	
- **Column & Lines**： how many numbers of columns and lines   
_COLUMN:_  ``$ awk -F `\t` {print NF; exit} snp_position.txt ``   
_LINE:_  `$ wc -l snp_position.txt`  

- **File size**： how large is the file `$ du -h snp_position.txt`

- **Inside the file**： open the file to see how the data exactly look like `$ less snp_position_txt`  
	
**_Summary_**  
From the above, we know that snp\_position.txt file includes **983 SNPs**' position information (ID, chromosome, etc.). Among these, what we are looking for are in **column 1, 3 and 4 **. These SNPs are in **10 chromosomes** and some are in multiple chromosomes while some also have unknown position.

# _Data Processing_ 
## SNP information preparation  
	$ cut -f 1,3,4 snp_position.txt | sort -k1,1 > snp_infor.txt  
  
 -  `cut` command is to extract three needed columns from the original file;     
 -  `sort` command is to do sorting by the 1st column (SNP_ID).    
## Separate _Maize_ and _Teosinte_ genotypes   
	$ grep -E "(ZMMIL|ZMMLR|ZMMMR|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk  > maize_genotype.txt  
	$ sed 's/Sample_ID/SNP_ID/' maize_genotype.txt | sort –k1,1 > maize_sgenotype.txt 
	$ grep -E "(ZMPBA|ZMPIL|ZMPJA|Group)" fang_et_al_genotypes.txt | cut -f 1,4-986 |awk -f transpose.awk > teosinte_genotype.txt  
	$ sed 's/Sample_ID/SNP_ID/' teosinte_genotype.txt | sort –k1,1 > teosinte_sgenotype.txt
 - `grep` command is to print out lines containing "ZMMIL", "ZMMLR" "ZMMMR" and "Group" ("ZMPBA", "ZMPIL" "ZMPJA" and "Group" for teosinte), which are maize samples and the header;
 - `cut` commands is to remove the 2 columns we don't need;
 - `awk` command is to transpose the table so that it has the same data frame with snp_infor.txt and we can join them later;
 - `sed` command is change the header in genotype file to the same with SNP file, so that we can join them later;
 - `sort` command is to sort by the 1st column;
 - new files saved as "maize\_sgenotype.txt" and "teosinte\_sgenotype.txt".  

## Combine genotype with SNP position      
	$join -1 1 -2 1 –t $'\t' snp_infor.txt maize_sgenotype.txt > maize_joint.txt  
	$join -1 1 -2 1 –t $'\t' snp_infor.txt teosinte_sgenotype.txt > teosinte_joint.txt				
 - `join` command is to combine the two file based on the 1st column of snp_infor.txt and the 1st column of maize_transposed_genotype.txt; 
 - new file saved as "maize_joint.txt"
## Separate SNPs based on Chromosome   
	$ for i in {1..10} ; do (awk '$1 ~ /SNP/' maize_joint.txt && awk '$2 == '$i'' maize_joint.txt) > maize_chr$i.txt ; done
	$ awk '$2 == "unknown"' maize_joint.txt > maize_unknown.txt
	$ awk '$2 == "multiple"' maize_joint.txt > maize_multiple.txt
	$ for i in {1..10} ; do (awk '$1 ~ /SNP/' teosinte_joint.txt && awk '$2 == '$i'' teosinte_joint.txt) > teosinte_chr$i.txt ; done
	$ awk '$2 == "unknown"' teosinte_joint.txt > teosinte_unknown.txt
	$ awk '$2 == "multiple"' teosinte_joint.txt > teosinte_multiple.txt
 - `for` command is used to do the loop for 10 chromosomes;
 - `awk` command is used to first print out header and then print out the records which feature pattern that field2 is the same with value of i;
 - new file saved as "maize_chr$i.txt" and "teosinte_Chr$i.txt", in which i is the number of chromosome.

## Sort SNPs based on position 

	$ for i in {1..10}; do (head -n 1 maize_chr$i.txt && tail -n +2 maize_chr$i.txt | sort -k3,3n )> incr_maize_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 maize_chr$i.txt && tail -n +2 maize_chr$i.txt | sort -k3r,3n ) | sed 's/?/-/g' > decr_maize_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 teosinte_chr$i.txt && tail -n +2 teosinte_chr$i.txt | sort -k3,3n )> incr_teosinte_chr$i.txt ; done
	$ for i in {1..10}; do (head -n 1 teosinte_chr$i.txt && tail -n +2 teosinte_chr$i.txt | sort -k3r,3n ) | sed 's/?/-/g' > decr_teosinte_chr$i.txt ; done
 - `for` command is used to do the loop for 10 files;
 - `head` and `tail` command are used to keep the header at top and then do the sorting on the other lines;
 - `sort` command is the key command here. We do the sorting based on the 3rd column, which shows the position of SNP. `-k3` means the result will be listed increasingly and `-k3r` means the reverse. `3n` means they are treated as numeric. 
 - `sed` command is used to switch the "?", which is encoded to be missing data, to "-";
 - new files are saves as incr\_maize\_chr$i.txt / incr\_teosinte\_chr$i.txt if their position is listed increasingly; decr\_maize\_chr$i.txt / decr\_teosinte\_chr$i.txt if their position is listed decreasingly.
# _File checking_  
  
 | Chr. |$wc -l |$wc -l | file_name |  
 | :-----: | :-----: | :-----:| :-----: | :-----: |  
 | -----| ----- | -----| ----- | ----- |
 | 1 | 155 | 156 | incr_maize_chr1.txt|  
| 2 | 127 | 128 | incr_maize_chr2.txt|  
| 3 | 107 | 108 | incr_maize_chr3.txt|  
| 4 | 91 | 92 | incr_maize_chr4.txt|  
| 5 | 122 | 123 | incr_maize_chr5.txt|  
| 6 | 76 | 77 | incr_maize_chr6.txt|  
| 7 |  97| 98 | incr_maize_chr7.txt|  
| 8 | 62 | 63 | incr_maize_chr8.txt|  
| 9 | 60 | 61 | incr_maize_chr9.txt|  
| 10 | 53 | 54 | incr_maize_chr10.txt|  
| multiple | 5 | 6 | maize_multiple.txt|  
| unknown | 26 | 27 | maize_unknown.txt|

 | Chr. | $wc -l | $wc -l |  file_name |
 |:-----: |:-----:|:-----:|:-----:| 
 |scasv|svas|asvs|asav|avsa|  
 | 1 | 155 | 156 | incr_maize_chr1.txt|  
 | 2 | 127 | 128 | incr_maize_chr2.txt|  
 | 3 | 107 | 108 | incr_maize_chr3.txt|  
 | 4 | 91 | 92 | incr_maize_chr4.txt|  
 | 5 | 122 | 123 | incr_maize_chr5.txt|  
 | 6 | 76 | 77 | incr_maize_chr6.txt|  
 | 7 |  97| 98 | incr_maize_chr7.txt|  
 | 8 | 62 | 63 | incr_maize_chr8.txt|  
 | 9 | 60 | 61 | incr_maize_chr9.txt|  
 | 10 | 53 | 54 | incr_maize_chr10.txt|  
 | multiple | 5 | 6 | maize_multiple.txt|  
 | unknown | 26 | 27 | maize_unknown.txt|