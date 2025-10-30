RAM_DATA SECTION DATA

ov_vs           DS 1
ov_pvs_av       DSW 1
ov_dly_er       DSW 1

ov_mis_flags    DSW 1
ov_ttc_flags    DSW 1

lv_dly_er       BIT ov_mis_flags.12
lv_lc_act       BIT ov_ttc_flags.0

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_lc       DB 0x01
c_lc_vs_max     DB 0x14
c_lc_pvs_min    DB 0x90

CAL_DATA ENDS


LAUNCH_CONTROL SECTION CODE
check_lc_configuration:
movb    rl4, c_conf_lc
jmpr    cc_Z, return_from_sub ; Return from the routine if c_conf_lc is zero meaning the function is disabled

jb      lv_lc_act, check_deactivation_tresholds ; Jump to the de-activation checks if launch control is already active

cmpb    rl4, #1
jmpr    cc_Z, check_activation_tresholds ; Jump to the activation checks if c_conf_lc is one meaning the function is activated when the clutch pedal is active
cmpb    rl4, #2
jmpr    cc_NZ, return_from_sub ; Return from the routines as an invalid launch control configuration has been detected

check_cru_active: ; c_conf_lc is two meaning the function is activated when both the cruise control and clutch pedal is active
jnb     lv_cru_main_swi, return_from_sub  ; Return from the routine if cruise control is not active

check_activation_tresholds:
movb    rl5, ov_vs
jmpr    cc_NZ, return_from_sub ; Return from the routine if the vehicle is stationary

jnb     lv_cs, return_from_sub ; Return from the routine if the clutch pedal is not pressed

movb    rl4, ov_pvs_av+1
cmpb    rl4, c_lc_pvs_min
jmpr    cc_ULT, return_from_sub ; Return from the routine if the accelerator pedal postion is below the threshold

enable_lc:
bset    lv_lc_act ; All activation checks passed signal that launch control is active
jmpr    cc_UC, suppress_rough_engine_detection

check_deactivation_tresholds:
movb    rl5, ov_vs ; Disable launch control if the vehicle speed exceeds the maximum vehicle speed threshold
cmpb    rl5, c_lc_vs_max
jmpr    cc_UGE, disable_lc

movb    rl4, ov_pvs_av+1 ; Disable launch control if the accelerator pedal position is below the threshold
cmpb    rl4, c_lc_pvs_min
jmpr    cc_ULT, disable_lc

suppress_rough_engine_detection:
mov     r6, #64h ; Delay engine roughness detection for 1 second
mov     ov_dly_er, r6
bset    lv_dly_er ; Activate engine roughness detection delay
jmpr    cc_UC, return_from_sub

disable_lc:
bclr    lv_lc_act ; One de-activation check passed, signal that launch control is not active

return_from_sub:
rets

CODE ENDS