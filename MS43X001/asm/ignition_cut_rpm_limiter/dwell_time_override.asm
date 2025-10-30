RAM_DATA SECTION DATA

ov_td               DS 1

ov_ign_cut_flags    DSW 1

lv_ign_cut          BIT ov_ign_cut_flags.0

RAM_DATA ENDS


DWELL_TIME_OVERRIDE SECTION CODE

jnb     word_FD50.lv_ign_cut, return_from_sub ; Return from the routine if ignition cut is not active

mov     ov_td, ZEROS ; Force the dwell time to zero to cut ignition

return_from_sub:
rets

TD_OVERRIDE ENDS