RAM_DATA SECTION DATA

ov_toil                 DS 1
ov_n_32                 DS 1
temp_bit_reg            DS 2
ov_icl_sup_ctr          DS 1

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_icl              DB 0x01
c_icl_sup_frq           DB 0x50

CAL_DATA ENDS


SHIFT_LIGHT SECTION CODE
check_icl_feature_active:
movb    rl4, c_conf_icl
jmpr    cc_Z, return_unmodified_can_bits

check_upshift_indicator:
mov     r12, #37BBh ; ldp_icl_seg_toil_address
mov     r13, #1Dh   ; ldp_icl_seg_toil_page
movbz   r14, ov_toil
calls   Get_Byte_Y_Axis_Value
mov     r12, #3BB2h ; id_icl_sup_n__toil_address
mov     r13, #1Eh   ; id_icl_sup_n__toil_page
calls   0Dh, Get_Byte_Value_2D_Table
mov     rl5, ov_n_32
cmpb    rl5, rl4
jmpr    cc_ULT, zero_icl_sup_ctr

check_icl_sup_ctr:
cmpb    rl4, ov_icl_sup_ctr
jmpr    cc_NZ, decrement_icl_sup_ctr

reset_icl_sup_ctr:
movbz   rl4, c_icl_sup_frq
movb    ov_icl_sup_ctr, rl4
bxor    lv_icl_sup, ONES.0
jmpr    cc_UC, check_lv_icl_sup

decrement_icl_sup_ctr:
subb    ov_icl_sup_ctr, ONES

check_lv_icl_sup:
jb      lv_icl_sup, get_toil_segments

disable_all_segments:
movb    rl6, #00h
jmpr    cc_UC, transfer_icl_bits

zero_icl_sup_ctr:
movb    ov_icl_sup_ctr, ZEROS

get_toil_segments:
mov     r12, #3BA2h ; id_icl_seg__toil_address
mov     r13, #1Eh   ; id_icl_seg__toil_page
calls   Get_Byte_Value_2D_Table
movb    rl6, rl4

get_n_segments:
mov     r12, #37C4h ; ldp_icl_seg_n_address
mov     r13, #1Dh   ; ldp_icl_seg_n_page
movbz   r14, ov_n_32
calls   0Dh, Get_Byte_Y_Axis_Value
mov     r12, #3BAAh ; id_icl_seg__n_address
mov     r13, #1Eh   ; id_icl_seg__n_page
calls   0Dh, Get_Byte_Value_2D_Table
orb     rl6, rl4
shl     r6, #4

transfer_icl_bits:
orb     ov_icl_can_bits, rl6
movb    rl4, ov_icl_can_bits

return_from_sub:
rets

return_unmodified_can_bits:
movb    rl4, ov_icl_can_bits
rets

SHIFT_LIGHT ENDS