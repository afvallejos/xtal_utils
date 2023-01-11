#!/bin/bash

###############################################################
### ref_template_rest.sh                     version 230111  ##
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
    LIBIN "ligand.cif" \
    XYZOUT "rame_refmac1.pdb" \
    HKLOUT "name_refmac1.mtz" \
    LIBOUT "name_lib.cif"\
    <<-ENDrest > rest-ref_summary.log
    # description: as they appear on the gui
    REFI -
    TYPE REST -
    RESI MLKF -
    METH CGMAT -
    BREF ISOT
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
    NCYC 20
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
    ! WEIGHT MATRIX 0.0
    ! WEIGHT NOEX MATRIX 0.0

    # Use jelly-body refinement with sigma:
    ! RIDG DIST SIGM 0.00
    
    # exclude data with freer label
    ! FREE 0.0

    # --- Setup geometric constraints
    
    # --- Setup non-crystallographic symmetry (NCS) restraints
    ! NCSR LOCAL

    # # --- external restraints
    EXTERNAL WEIGHT SCALE 0.0 # sigma used in restraints
    EXTERNAL WEIGHT GMWT 0.0 # Apply Geman-McClure weight
    EXTERNAL DMAX 4.2 # maximum interatomic distance
    EXTERNAL USE MAIN # use main chain only


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
        VDWPROB 0.0 - # increase the vdw radius of non-ion atoms
        IONPROB 0.0 - # increase ionic radius of potential ion atoms
        RSHRINK 0.0   # shrink the are of the mask after calculation

    # --- geometric parameters
    # restraint weight
    DIST 0.0     
    ANGLE 0.0
    TEMP -
        0.0 - # overall
        0.0 - # main chain
        0.0 - # main chain angle
        0.0 - # side chain bond
        0.0   # side chain angle
    PLAN -
        0.0 - # overall
        0.0 - # peptide
        0.0   # aromatic
    CHIR -
        0.0 - # overall 
        0.0   # chiral
    TORSION 0.0    
    NCSR -
        0.0 - # overall
        # positional restraints
        0.0 - # tight
        0.0 - # medium
        0.0 - # loose
        # Bfactor restraints
        0.0 - # tight
        0.0 - # medium
        0.0   # loose
    # vdw contacts
    VAND -
        OVERALL 0.0 -
        # sigmas for types of non-bonding interaction
        SIGMA VDW 0.0 - # Non-bonding
        SIGMA HBOND 0.0 - # H-bonding
        SIGMA METAL 0.0 - # metal-ion interactions
        SIGMA TORS 0.0 - # 1-4 atoms in torsion
        # Set increments for non-bonded interactions
        INCR TORS 0.0 - # 1-4 atoms in torsion
        INCR ADHB 0.0 - # H-bond pair (not hydrogen atom)
        INCR AHHB 0.0 # H-bonded (one is hydrogen atom)
    # set limits for B values
    BLIM 0.0 0.0
    

    # --- external script file
    @/path/to/external_refinement_parameters.com
    END
ENDrest




