RAM_DATA SECTION DATA

ov_vs               DS 1
ov_nls_ral_n_max    DS 1
ov_pvs_av           DSW 1
ov_dly_er           DSW 1

ov_mis_flags        DSW 1
ov_ttc_flags        DSW 1

lv_dly_er           BIT ov_mis_flags.12
lv_nls_act          BIT ov_ttc_flags.1

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_nls          DB 0x01
c_nls_vs_min        DB 0x14
c_nls_pvs_min       DB 0x90
c_nls_n_max_ofs     DB 0x06

CAL_DATA ENDS


NO_LIFT_SHIFT SECTION CODE
check_nls_configuration:
movb    rl4, c_conf_nls
jmpr    cc_Z, return_from_sub ; Return from the routine if c_conf_nls is zero meaning the function is disabled

jb      lv_nls_act, check_deactivation_tresholds ; Jump to the de-activation checks if no lift shift is already active

cmpb    rl4, #1
jmpr    cc_Z, check_activation_tresholds ; Jump to the activation checks if c_conf_nls is one meaning the function is activated when the clutch pedal is active
cmpb    rl4, #2
jmpr    cc_NZ, return_from_sub ; Return from the routines as an invalid no lift shift configuration has been detected

check_cru_active: ; c_conf_nls is two meaning the function is activated when both the cruise control and clutch pedal is active
jnb     lv_cru_main_swi, return_from_sub  ; Return from the routine if cruise control is not active

check_activation_tresholds:
jnb     lv_cs, return_from_sub ; Return from the routine if the clutch pedal is not pressed

movb    rl5, ov_vs ; Return from the routine if the vehicle speed does not exceed the minimum vehicle speed threshold
cmpb    rl5, c_nls_vs_min
jmpr    cc_ULT, return_from_sub

movb    rl4, ov_pvs_av+1 ; Return from the routine if the accelerator pedal postion is below the threshold
cmpb    rl4, c_nls_pvs_min
jmpr    cc_ULT, return_from_sub

enable_nls:
movbz   r12, ov_n_32 ; Calculcate the engine speed limiter limit based on the current engine speed
movbz   r13, c_nls_n_max_ofs
calls   0Bh, MS4x_Signed_Byte_Offset_With_Bounds_Check
movb    ov_nls_ral_n_max, rl4
bset    lv_nls_act ; All activation checks passed signal that no lift shift is active
jmpr    cc_UC, suppress_rough_engine_detection

check_deactivation_tresholds:
jnb     lv_cs, disable_nls ; Disable no lift shift if the clutch pedal is released

movb    rl4, ov_pvs_av+1 ; Disable no lift shift if the accelerator pedal position is below the threshold
cmpb    rl4, c_nls_pvs_min
jmpr    cc_ULT, disable_nls

suppress_rough_engine_detection:
mov     r6, #64h ; Delay engine roughness detection for 1 second
mov     ov_dly_er, r6
bset    lv_dly_er ; Activate engine roughness detection delay
jmpr    cc_UC, return_from_sub

disable_nls:
bclr    lv_nls_act ; One de-activation check passed, signal that no lift shift is not active

return_from_sub:
rets

NO_LIFT_SHIFT ENDS