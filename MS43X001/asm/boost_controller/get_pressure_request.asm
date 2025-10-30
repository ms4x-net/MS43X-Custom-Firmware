RAM_DATA SECTION DATA

ov_ff_bc_fac        DS 1
ov_req_msw          DS 1
ov_gear             DS 1

ov_n                DSW 1
ov_pvs_av           DSW 1
ov_map              DSW 1
ov_map_req          DSW 1

ov_bc_flags         DSW 1

lv_ob_prot          BIT ov_bc_flags.3

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_bc               DB 0x00
c_bc_scr_req_ofs_e85    DB 0x00
c_bc_scr_req_ofs_ron98  DB 0x00

CAL_DATA ENDS


GET_PRESSURE_REQUEST SECTION CODE

check_bc_config:
movb    rl4, c_conf_bc
cmpb    rl4, #2
jmpr    cc_NZ, zero_map_req ; Zero map_req if the boost controller is not configured for closed loop operation

loc_C4574:
jb      lv_ob_prot, zero_map_req ; Zero map_req if the overboost protection is active
mov     r12, #3EA4h
mov     r13, #1Dh
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #0F1h
mov     r13, #1Dh
movbz   r14, ov_gear
calls   0Dh, Get_IP_Byte_X_Axis
mov     r12, #1B98h
mov     r13, #1Fh
calls   0Dh, Get_IP_Word_3D_Table
mov     r6, r4
mov     r12, #1AFCh
mov     r13, #1Fh
calls   0Dh, Get_IP_Word_3D_Table
mov     r13, r4
movbs   r14, ov_ff_bc_fac
mov     r12, r6
calls   0Dh, Blend_Values_Return_Byte
mov     r6, r4
mov     r12, #3EDAh
mov     r13, #1Dh
mov     r14, ov_pvs_av
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #1B8Ch
mov     r13, #1Fh
calls   0Dh, Get_IP_Word_2D_Table
mov     r12, r6
mov     r13, r4
calls   0Dh, sub_D1900
jb      word_FD18.lv_cru_main_swi, update_map_req ; Skip boost scramble logic if cruise control is inactive
movb    rl5, ov_req_msw
cmpb    rl5, #4
jmpr    cc_NZ, update_map_req ; Skip boost scramble logic if the increment cruise speed button (+) is not being held

boost_scramble:
mov     r6, r4
movbz   r12, c_bc_scr_req_ofs_e85
movbz   r13, c_bc_scr_req_ofs_ron98
movbs   r14, ov_ff_bc_fac
calls   0Dh, Blend_Values_Return_Byte
shl     r4, #8
mov     r12, r6
mov     r13, r4
calls   0Dh, Add_Unsigned_Words_With_Bounds_Check ; Apply boost scramble offset to the new map_req

update_map_req:
mov     ov_map_req, r4
jmpr    cc_UC, return_from_sub

zero_map_req:
mov     ov_map_req, ZEROS

return_from_sub:
rets

GET_PRESSURE_REQUEST ENDS