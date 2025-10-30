RAM_DATA SECTION DATA

ov_n_max_max_av     DS 1
ov_n_max_av         DS 1
ov_n_32             DS 1
ov_nls_ral_n_max    DS 1

ov_ttc_flags         DSW 1

lv_lc_act           BIT ov_ttc_flags.0
lv_nls_act          BIT ov_ttc_flags.1
lv_ral_act          BIT ov_ttc_flags.2

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_lc_n_max      DB 0x6E

CAL_DATA ENDS


N_MAX_OVERRIDE SECTION CODE
check_for_active_function:
jnb     lv_lc_act, retrieve_lc_n_max ; If launch control is active retrieve the corresponding engine speed limit
jnb     lv_nls_act, retrieve_nls_ral_n_max ; If no lift shift is active retrieve the corresponding engine speed limit
jnb     lv_ral_act, retrieve_nls_ral_n_max ; If rolling anti lag is active retrieve the corresponding engine speed limit
jmpr    cc_UC, return_from_sub

retrieve_lc_n_max:
movb    rl4, c_lc_n_max
jmpr    cc_UC, update_n_max

retrieve_nls_ral_n_max:
movbz   r13, ov_nls_ral_n_max

update_n_max: ; Override the current engine speed limit
movb    ov_n_max_max, rl4
movb    ov_n_max, rl4

return_from_sub:
rets

N_MAX_OVERRIDE ENDS