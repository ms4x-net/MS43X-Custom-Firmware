RAM_DATA SECTION DATA

ov_variant_flags    DSW 1
ov_ttc_flags        DSW 1

lv_at               BIT ov_variant_flags.0

lv_lc_act           BIT ov_ttc_flags.0
lv_nls_act          BIT ov_ttc_flags.1
lv_ral_act          BIT ov_ttc_flags.2

RAM_DATA ENDS


TTC_SELECTION SECTION CODE

check_for_active_function:
jb      lv_lc_act, call_lc_function ; If launch control is already active jump directly to the launch control routine
jb      lv_nls_act, call_nls_function ; If no lift shift is already active jump directly to the no lift shift routine
jb      lv_ral_act, call_ral_function ; If rolling anti lag is already active jump directly to the rolling anti lag routine
jb      lv_at, call_ral_function ; If the vehicle has an automatic transmission skip directly to rolling anti lag routine

call_lc_function:
calls   MS4x_Launch_Control
jb      lv_lc_act, return_from_sub ; If launch control has activated return from the routine

call_nls_function:
calls   MS4x_No_Lift_Shift
jb      lv_nls_act, return_from_sub ; If no lift shift has activated return from the routine

call_ral_function:
calls   MS4x_Rolling_Anti_Lag

return_from_sub:
rets

TTC_SELECTION ENDS