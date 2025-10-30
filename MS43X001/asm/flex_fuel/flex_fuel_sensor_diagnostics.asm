RAM_DATA SECTION DATA

ov_n_32             DS 1
ov_n_max_av         DS 1
ov_n_max_hys_max    DS 1
ov_dly_er           DSW 1

ov_state_flags      DSW 1
ov_mis_flags        DSW 1
ov_mu_flags         DSW 1
ov_mu_2_flags       DSW 1
ov_ign_cut_flags    DSW 1

lv_dly_er           BIT ov_mis_flags.12
lv_n_lim_etc_mon    BIT ov_mu_flags.12
lv_n_lim_etc_mon2   BIT ov_mu_2_flags.1
lv_n_max            BIT ov_state_flags.15
lv_ign_cut          BIT ov_ign_cut_flags.0

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_n_max        DB 0x01

CAL_DATA ENDS


FLEX_FUEL_DIAG SECTION CODE
rl4, c_conf_ff
jmpr    cc_Z, set_diag_values
mov     r4, ov_v_ff_input
and     r4, #3FFh
shr     r4, #2
movb    ov_v_ff, rl4

check_input_high_limit:
cmpb    rl4, c_ff_diag_max
jmpr    cc_ULE, check_input_low_limit
movb    rl5, #2
movb    ov_err_state, rl5
jmpr    cc_UC, check_error

check_input_low_limit:
movb    rl4, ov_v_ff
cmpb    rl4, c_ff_diag_min
jmpr    cc_NC, check_error
movb    rl4, #1
movb    ov_err_state, rl4

check_error:
jnb     lv_igk, no_error_detected
mov     r12, #ov_abc_ff_sensor
mov     r13, #DTC_Table_94_Flex_Fuel_Sensor
movbz   r14, c_abc_inc_ff
movbz   r15, c_abc_max_ff
calls   0Ah, Check_Error_With_Anti_Bounce
bmov    lv_ff_err, lv_dtc_state
jmpr    cc_UC, error_detected

no_error_detected:
movb    ov_err_state, ZEROS

error_detected:
jb      lv_ff_err, set_substitute_factors

get_ff_factors:
mov     r12, #1250h ; ldp_ff__v_ff_address
mov     r13, #1Dh   ; ldp_ff__v_ff_page
movbz   r14, ov_v_ff
calls   0Dh, Get_IP_Byte_Y_Axis
mov     r12, #3EE4h ; ip_ff__v_ff_address
mov     r13, #1Eh   ; ip_ff__v_ff_page
calls   0Dh, Get_IP_Byte_2D_Table
movbz   r12, rl4
movbz   r13, ov_ff
movbz   r14, c_ff_lgrd
calls   0Dh, Apply_Limit_Gradient
movb    ov_ff, rl4
mov     r12, #37AAh ; ldpm_ff_fac__ff_address
mov     r13, #1Dh   ; ldpm_ff_fac__ff_page
movbz   r14, rl4
calls   0Dh, Get_IP_Byte_Y_Axis
mov     r12, #1654h ; ip_ff_fac_ti__ff_address
mov     r13, #1Fh   ; ip_ff_fac_ti__ff_page
calls   0Dh, Get_IP_Byte_2D_Table
subb    rl4,
movb    ov_ff_fac_ti, rl4
mov     r12, #1664h ; ip_ff_fac_iga__ff_address
mov     r13, #1Fh   ; ip_ff_fac_iga__ff_page
calls   0Dh, Get_IP_Byte_2D_Table
subb    rl4,
movb    ov_ff_fac_iga, rl4
mov     r12, #1674h ; ip_ff_fac_bc__ff_address
mov     r13, #1Fh   ; ip_ff_fac_bc__ff_page
calls   0Dh, Get_IP_Byte_2D_Table
subb    rl4, #80h
movb    ov_ff_bc_fac, rl4
mov     r12, #1684h ; ip_fac_ff_vanos__ff_address
mov     r13, #1Fh   ; ip_fac_ff_vanos__ff_page
calls   0Dh, Get_IP_Byte_2D_Table
subb    rl4, #80h
movb    ov_ff_fac_vanos, rl4
jmpr    cc_UC, return_from_sub

set_substitute_factors:
movb    ov_ff, ZEROS
movb    rl4, c_ff_fac_ti_diag_sub
subb    rl4, #80h
movb    ov_ff_fac_ti, rl4
movb    rl5, c_ff_fac_iga_diag_sub
subb    rl5, #80h
movb    ov_ff_fac_iga, rl5
movb    rl4, c_ff_fac_bc_diag_sub
subb    rl4, #80h
movb    ov_ff_bc_fac, rl4
movb    rl4, c_ff_fac_vanos_diag_sub
subb    rl4, #80h
movb    ov_ff_fac_vanos, rl4

return_from_sub:
rets

FLEX_FUEL_DIAG ENDS