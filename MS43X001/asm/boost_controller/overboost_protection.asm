RAM_DATA SECTION DATA

ov_ff_bc_fac        DS 1
ov_map              DSW 1

ov_bc_flags         DSW 1

lv_ob_prot          BIT ov_bc_flags.3

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_ob_thr_e85        DB 0x5E
c_ob_thr_hys_e85    DB 0x2F
c_ob_thr_ron98      DB 0x5E
c_ob_thr_hys_ron98  DB 0x2F

CAL_DATA ENDS


OVERBOOST_PROTECTION SECTION CODE

get_ob_protection_treshold:
; Derive the overboost protection threshold based on the flex fuel blending factor
movbz   r12, c_ob_thr_hys_e85
movbz   r13, c_ob_thr_hys_ron98
movbs   r14, ov_ff_bc_fac
calls   0Dh, Blend_Values_Return_Byte
movbz   r5, rl4
movbz   r12, c_ob_thr_e85
movbz   r13, c_ob_thr_ron98
movbs   r14, ov_ff_bc_fac
calls   0Dh, Blend_Values_Return_Byte

check_activation_treshold:
cmpb    rl4, ov_map+1
jmpr    cc_C, activate_ob_protection ; Jump to overboost activation logic if activation threshold is exceeded
jnb     lv_ob_prot, return_from_sub ; Return from routine if overboost protection is not active

check_deactivation_treshold:
movbz   r12, rl4
mov     r13, r5
calls   0Dh, Subtract_Unsigned_Bytes_With_Bound_Check
cmpb    rl4, ov_map+1
jmpr    cc_C, return_from_sub ; Return from routine if deactivation threshold is not exceeded

deactivate_ob_protection:
movb    ov_inh_iv_bc, ZEROS
movb    rl4, ov_inh_iv_ign_coil
orb     rl4, ov_inh_iv_fcut
orb     rl4, ov_inh_iv_tps_ad
orb     rl4, ov_inh_iv_mon
orb     rl4, ov_inh_iv_supp_st_act
orb     rl4, ov_inh_iv_tq
orb     rl4, ov_inh_iv_bc
orb     rl4, ov_inh_iv_mis
movb    ov_inh_iv, rl4
bclr    lv_ob_prot
jmpr    cc_UC, return_from_sub

activate_ob_protection:
cmpb    rl4, ov_map_prev_2+1 ; Verify that the activation threshold was also exceeded two cycles before
jmpr    cc_NC, return_from_sub
movb    rl5, #3Fh
movb    ov_inh_iv_bc, rl5
movb    rl4, ov_inh_iv_ign_coil
orb     rl4, ov_inh_iv_fcut
orb     rl4, ov_inh_iv_acr
orb     rl4, ov_inh_iv_tps_ad
orb     rl4, ov_inh_iv_mon
orb     rl4, ov_inh_iv_supp_st_act
orb     rl4, ov_inh_iv_tq
orb     rl4, ov_inh_iv_bc
orb     rl4, ov_inh_iv_mis
movb    ov_inh_iv, rl4
bset    lv_ob_prot

return_from_sub:
rets

OVERBOOST_PROTECTION ENDS