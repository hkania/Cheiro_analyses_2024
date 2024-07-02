## Here is information regarding the scripts used for generating the cheiro reference genome. 
* The original genome generated using the script `stitchScaffolds2.sh` did not include all of the individual scaffolds, only the superscaffold.
* The bwa and picard scripts were run to index the reference genome that included all of the scaffolds after adding the non-super scaffold sequences to the reference genome.
* I ran a few commands to ammend the scaffold lists in order to run the submission script `stitch_scaffolds_R.sh` for the R script `stitchScaffolds_extract2.R` that would generate a stitched scaffold which included all of the individual cheiro scaffolds and the important information regarding their location.
* The final reference genome and dictionaries etc can be found at this path on the DCC cluster `/datacommons/yoderlab/users/hkania/cheiro/reference_genome`
  * Hannah may need to change permissions for other researchers to access in the future. Just reach out if necessary! The files are quite large to host here.
