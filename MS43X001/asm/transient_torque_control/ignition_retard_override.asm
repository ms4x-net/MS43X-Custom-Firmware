RAM_DATA SECTION DATA

ov_tco          DS 1
ov_iga_rtd      DS 1
ov_ff_iga_fac   DS 1

ov_ttc_flags    DSW 1

lv_lc_act       BIT ov_ttc_flags.0
lv_nls_act      BIT ov_ttc_flags.1
lv_ral_act      BIT ov_ttc_flags.2

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_lc_iga_rtd_e85    DB 0x48
c_lc_iga_rtd_ron98  DB 0x48
c_nls_iga_rtd_e85   DB 0x48
c_nls_iga_rtd_ron98 DB 0x48
c_ral_iga_rtd_e85   DB 0x48
c_ral_iga_rtd_ron98 DB 0x48

CAL_DATA ENDS


IGA_RTD_OVERRIDE SECTION CODE

check_for_active_function:
jb      lv_lc_act, retrieve_lc_iga_rtd ; If launch control is active retrieve the corresponding ignition retard
jb      lv_ral_act, retrieve_nls_iga_rtd ; If no lift shift is active retrieve the corresponding ignition retard
jb      lv_nls_act, retrieve_ral_iga_rtd ; If rolling anti lag is active retrieve the corresponding ignition retard
jmpr    cc_UC, return_from_sub

retrieve_lc_iga_rtd:
movbz   r12, c_lc_iga_rtd_e85
movbz   r13, c_lc_iga_rtd_ron98
cc_UC   calculate_final_iga_rtd:

retrieve_nls_iga_rtd:
movbz   r12, c_nls_iga_rtd_e85
movbz   r13, c_nls_iga_rtd_ron98
cc_UC   calculate_final_iga_rtd:

retrieve_ral_iga_rtd:
movbz   r12, c_ral_iga_rtd_e85
movbz   r13, c_ral_iga_rtd_ron98

calculate_final_iga_rtd: ; Derive the final AFR target based on the flex fuel blending factor
movbs   r14, ov_ff_iga_fac
calls   Blend_Byte_Values

update_iga_rtd:
movb    ov_iga_rtd, rl4

return_from_sub:
rets

IGA_RTD_OVERRIDE ENDS