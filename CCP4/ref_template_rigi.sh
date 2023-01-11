#!/bin/bash

###############################################################
### ref_template_rigi.sh                     version 230111  ##
### (C) 2022 Adams Vallejos                                  ##
###############################################################

# ANYTHING INPUT ON A LINE AFTER “!” OR “#” IS IGNORED
# # Used for comments and ! Used for optional commands
# LINES CAN BE CONTINUED BY USING A MINUS (-) SIGN
# Uppercase text are commands, lowercase comments
# CCP4 VERSION 8.0.006 USED TO TEST THIS SCRIPT

refmac5 \
    XYZIN "coordinates.pdb" \
    HKLIN "name.mtz" \
    XYZOUT "name_refmac1.pdb" \
    HKLOUT "name_refmac1.mtz" \
    <<-ENDrigi > rigi-ref_summary.log
    # description: as they appear on the gui
    REFI -
        TYPE RIGID - #  no prior phase information
        RESI MLKF -
        METH CGMAT -
        BREF OVER
    ! TWIN  # twin refinement option
    LABIN  -    # read labels from input file
        FP=FP SIGFP=SIGFP -   # amplitude based refinement
        ! IP=IP SIGIP=SIGIP - # intensity based refinement
        FREE=FREE

    # --- harvesting keywords,
    PNAME project_name    # project name from input mtz
    DNAME dataset_name    # dataset name from input mtz
    RSIZE 80              # max row width of deposit file
    ! NOHARVEST             # don't write deposit file

    # --- refinement parameters
    RIGID NCYCLE 20
    REFI RESOLUTION 2.0 40.0

    MAKE CHECK NONE
    MAKE -
        HYDROGEN YES - # if present in file
        ! HYDROGEN ALL - # generate all hydrogens
        ! HYDROGEN NO - # ignore even if present in file
        HOUT YES -      # output hydrogens to output file
        PEPTIDE NO -
        CISPEPTIDE YES -
        SSBRIDGE YES -
        SYMMETRY YES -
        SUGAR YES -
        CONNECTIVITY NO -
        LINK NO
    
    # automatic weighting, using experimental sigmas to weight xrray terms
    WEIGHT AUTO # ensure rmsd bond between 0.015 and 0.025
    # automatic weighting without experimental sigmas
    ! WEIGHT NOEX AUTO
    # weighting term, default 0.5, tight 0.1(lowres data), loose 20 (hires data)
    ! WEIGHT MATRIX 11.0
    ! WEIGHT NOEX MATRIX 11.0

    # exclude data with freer label
    ! FREE 69

    #  --- rigid domains definition
    RIGID GROUP 1 FROM 1 A TO 234 A # ONE FOR EVERY HELIX
        ! EXCL SCHA -           #  exclude side chain
        # initialise rotation amd translation parameters for this domain
        ! EULER 0.0 0.0 0.0 - # rotation
        ! TRANS 0.0 0.0 0.0   # translation

    # --- monitoring and output options
    ! PERFORM MAP SHARPENING
    ! MAPC SHAR -
    !   0.0 -        # manually set b value
    !   ALPHA 0.0    # and/or alpha value

    ! MONITOR NONE - # no monitoring
    ! MONITOR FEW - # only overall statistics
    MONITOR MEDIUM - # only overall statistics
    ! MONITOR MANY - # overall statistics and outliers monitored at every cycle 
    # sigma cutoffs for monitoring levels
        TORSION 10.0 -
        DISTANCE 10.0 -
        ANGLE 10.0 -
        PLANE 10.0 -
        VDWREST 3.0 -
        CHIRAL 10.0 -
        BFACTOR 10.0 -
        BSPHERE 10.0 -
        RBOND 10.0 -
        NCSR 10.0

    LABOUT -   
        FC=FC -             # Fcalc
        PHIC=PHIC -         # PHICalc
        DELFWT=DELFWT -     # MFoDFc
        PHDELWT=PHDELWT -   # PHImFoDFc
        FWT=FWT -           # 2mFoDFc
        PHWT=PHWT -         # PHI2mFoDFc
        FOM=FOM             # figure of merit

    # --- scaling
    SCAL -
        TYPE SIMP RESO 2.0 40.0 - # use simple scaling
        LSSC -
        ANISO -
        # use experimental sigmas
        EXPE - 
        ! FREE # scale using free set of reflections
    # calculate contribution from solvent region
    SOLVENT YES
    # solvent mask calculation
        ! VDWPROB 1.0 - # increase the vdw radius of non-ion atoms
        ! IONPROB 2.0 - # increase ionic radius of potential ion atoms
        ! RSHRINK 3.0   # shrink the are of the mask after calculation


    # --- external restraints
    EXTERNAL WEIGHT SCALE 10.0 # sigma used in restraints
    EXTERNAL DMAX 4.2 # maximum interatomic distance
    EXTERNAL USE MAIN # use main chain only

    # --- external script file
    ! @/path/to/external_refinement_parameters.com
    END
ENDrigi