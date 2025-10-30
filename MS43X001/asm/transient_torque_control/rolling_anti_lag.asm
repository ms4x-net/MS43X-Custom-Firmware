RAM_DATA SECTION DATA

ov_req_msw      DS 1
ov_pvs_av       DSW 1
ov_dly_er       DSW 1

ov_mis_flags    DSW 1
ov_ttc_flags    DSW 1

lv_dly_er       BIT ov_mis_flags.12
lv_ral_act      BIT ov_ttc_flags.2

RAM_DATA ENDS

CAL_DATA SECTION CONST

c_conf_ral      DB 0x01
c_ral_pvs_min   DB 0x90
c_ral_n_max_ofs DB 0x06

CAL_DATA ENDS


ROLLING_ANTI_LAG SECTION CODE
check_ral_configuration:
movb    rl4, c_conf_ral
jmpr    cc_Z, return_from_sub ; Return from the routine if c_conf_ral is zero meaning the function is disabled
jb      lv_ral_act, check_deactivation_tresholds ; Jump to the de-activation checks if rolling anti lag is already active

check_activation_tresholds:
jb      lv_cru_main_swi, return_from_sub  ; Return from the routine if cruise control is active

movb    rl5, ov_req_msw
cmpb    rl5, #6
jmpr    cc_NZ, return_from_sub  ; Return from the routine if the decrement cruise speed button (-) is not being held

movb    rl4, ov_pvs_av+1
cmpb    rl4, c_ral_pvs_min
jmpr    cc_ULT, return_from_sub ; Return from the routine if the accelerator pedal postion is not above or equal to the threshold

enable_ral:
movbz   r12, ov_n_32 ; Calculcate the engine speed limiter limit based on the current engine speed
movbz   r13, c_ral_n_max_ofs
calls   0Bh, MS4x_Signed_Byte_Offset_With_Bounds_Check
movb    ov_nls_ral_n_max, rl4
bset    lv_ral_act ; All activation checks passed signal that rolling anti lag is active
jmpr    cc_UC, suppress_rough_engine_detection

check_deactivation_tresholds:
jb      lv_cru_main_swi, disable_ral ; Disable rolling anti lag if cruise control is active

movb    rl5, ov_req_msw ; Disable rolling anti lag if the decrement cruise speed button (-) is not being held
cmpb    rl5, #6
jmpr    cc_NZ, disable_ral

movb    rl4, ov_pvs_av+1 ; Disable launch control if the accelerator pedal position is below the threshold
cmpb    rl4, c_ral_pvs_min
jmpr    cc_ULT, disable_ral

suppress_rough_engine_detection:
mov     r6, #64h ; Delay engine roughness detection for 1 second
mov     ov_dly_er, r6
bset    lv_dly_er ; Activate engine roughness detection delay
jmpr    cc_UC, return_from_sub

disable_ral:
bclr    lv_ral_act ; One de-activation check passed, signal that rolling anti lag is not active

return_from_sub:
rets

ROLLING_ANTI_LAG ENDS