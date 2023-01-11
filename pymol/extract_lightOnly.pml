###############################################################
### (C) 2022 Adams Vallejos                version 23.01.05  ##
###############################################################
#
# USAGE:
# FROM PYMOL:
#		load extract_lightOnly.pml
#
# FROM TERMINAL:
#		pymol -c extract_lightOnly.pml
#
reinitialize

# LOAD A LIGHT-ACTIVATED STRUCTURE WITH THE 13-CIS RETINAL
# ^ANY LIGHT-STRUCTURE WOULD WORK
# 5b6w: 0.016us,
# 5h2h: 0.04us,
# 5h2i: 0.11us,
# 5h2j: 0.29us,
# 5b6x: 0.76us,
# 5h2k: 2.0us,
# 5h2l: 5.25us,
# 5h2m: 13.8us,
# 5b6y: 36.2us,
# 5h2n: 95.2us,
# 5h2o: 250.0us,
# 5h2p: 657.0us,
# 5b6z: 1725us,

# fetch 5b6z, bR_light
fetch 5h2p, bR_light

# REMOVE WATER MOLECULES
remove resn hoh

# REMOVE LIPIDS, THE RETINALS HAVE LOWER OCCUPANCY THAN 1
remove organic & (q=1)

# REMOVE THE DARK PART, VERIFY THE EXACT OCCUPANCY LEVEL
# remove (q=0.66)
 # 5h2p
 remove (q=0.8)

# GIVE FULL OCCUPANCY TO THE  LIGHT PART
alter (q=0.2), q=1.00

# save input/RET_13cis.pdb, RET_13cis, state=-1
