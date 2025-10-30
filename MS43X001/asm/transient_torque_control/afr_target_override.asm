RAM_DATA SECTION DATA

ov_ti_af_target DS 1
ov_ff_ti_fac    DS 1

ov_ttc_flg      DSW 1

lv_lc_act       BIT ov_ttc_flg.0
lv_nls_act      BIT ov_ttc_flg.1
lv_ral_act      BIT ov_ttc_flg.2

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_lc_af_target_e85      DB 0x57
c_lc_af_target_ron98    DB 0x82
c_nls_af_target_e85     DB 0x57
c_nls_af_target_ron98   DB 0x82
c_ral_af_target_e85     DB 0x57
c_ral_af_target_ron98   DB 0x82

CAL_DATA ENDS


AF_TARGET_OVERRIDE SECTION CODE

check_for_active_function:
jnb     lv_lc_act, retrieve_lc_af_target
jnb     lv_nls_act, retrieve_nls_af_target
jnb     lv_ral_act, retrieve_ral_af_target
jmpr    cc_UC, return_from_sub

retrieve_lc_af_target:
movbz   r12, c_lc_af_target_e85
movbz   r13, c_lc_af_target_ron98
cc_UC   update_af_target:

retrieve_nls_af_target:
movbz   r12, c_nls_af_target_e85
movbz   r13, c_nls_af_target_ron98
cc_UC   update_af_target:

retrieve_ral_af_target:
movbz   r12, c_ral_af_target_e85
movbz   r13, c_ral_af_target_ron98

update_af_target: ; Derive the final AFR target based on the flex fuel blending factor
movbs   r14, ov_ff_ti_fac
calls   Blend_Byte_Values

check_current_af_target: ; Check if the current AFR target is richer than the LC/NLS/RAL target. Skip override if it's not richer
movb    rl5. ov_ti_af_target
cmpb    rl4, rl5
jmpr    cc_SGE, return_from_sub

update_ov_ti_af_target:
movb    ov_ti_af_target, rl4

return_from_sub:
rets

AF_TARGET_OVERRIDE ENDS