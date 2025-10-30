; Based on C167 Boost Controller Developed by prj
; https://github.com/prj/C167BoostControl

RAM_DATA SECTION DATA

ov_n                    DSW 1
ov_map                  DSW 1
ov_map_req              DSW 1
ov_bc_abs_err           DSW 1
ov_bc_ld_err            DSW 1
ov_bc_i_term            DSW 1
ov_bc_pilot_prev        DSW 1
ov_bc_map_grd           DSW 1
ov_bc_p_term            DSW 1
ov_bc_i_term            DSW 1
ov_bc_d_term            DSW 1
ov_bc_output            DSW 1

ov_err_flags            DSW 1
ov_bc_flags             DSW 1

lv_err_load_input       BIT ov_err_flags.6
lv_ob_prot              BIT ov_bc_flags.3
lv_bc_dynm              BIT ov_bc_flags.4

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_conf_bc               DB 0x00
c_bc_map_thr            DW 0x33D2
c_bc_map_req_thr        DW 0x33D2
c_bc_pwm_min            DW 0x0000
c_bc_pwm_max            DW 0x4595
c_bc_i_max_thr          DW 0x04B6
c_bc_scr_req_ofs_e85    DW 0x0000
c_bc_scr_req_ofs_ron98  DW 0x0000


CAL_DATA ENDS


BOOST_CONTROLLER SECTION CODE
check_bc_states:
jb      lv_err_load_input, disable_output
jb      lv_ob_prot, disable_output
movb    rl4, c_conf_bc
jmpr    cc_NZ, check_if_open_loop
jmpa    cc_UC, return_from_sub

disable_output:
mov     r4, #0
jmpa    cc_UC, set_bc_output

check_if_open_loop:
cmpb    rl4, #1
jmpr    cc_NZ, closed_loop_operation

open_loop_operation:
mov     r4, ov_map
cmp     r4, c_bc_map_thr
jmpr    cc_C, set_pwm_min
mov     r12, #3EA4h ; ldpm_bc_n_address
mov     r13, #1Dh   ; ldpm_bc_n_page
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #1994h ; ip_bc_fixed_pwm__n_address
mov     r13, #1Fh   ; ip_bc_fixed_pwm__n_page
calls   0Dh, Get_IP_Word_2D_Table
jmpa    cc_UC, clamp_output

closed_loop_operation:
mov     r4, ov_map_req
cmp     r4, c_bc_map_req_thr
jmpr    cc_NC, calculate_ld_err

set_pwm_min:
mov     r4, c_bc_pwm_min
jmpa    cc_UC, set_bc_output

calculate_ld_err:
mov     r12, ov_map_req
mov     r13, ov_map
calls   0Dh, Signed_Subtraction_Return_Word
mov     ov_bc_ld_err, r4
jmpr    cc_NN, loc_C4382
neg     r4

update_bc_dynm_state:
mov     ov_bc_abs_err, r4
mov     r4, ov_bc_ld_err
jmpr    cc_N, clear_bc_dynm
cmp     r4, c_bc_i_max_thr
jmpr    cc_N, clear_bc_dynm
set_bc_dynm:
bset    lv_bc_dynm
jmpr    cc_UC, get_pilot_value
clear_bc_dynm:
bclr    lv_bc_dynm

get_pilot_value:
mov     r12, #3EA4h ; ldpm_bc_n_address
mov     r13, #1Dh   ; ldpm_bc_n_page
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #3EBEh ; ldp_bc_map_req_address
mov     r13, #1Dh   ; ldp_bc_map_req_page
mov     r14, ov_map_req
calls   0Dh, Get_IP_Word_X_Axis
mov     r12, #19ACh ; ip_bc_pwm_pilot__map_req__n_address
mov     r13, #1Fh   ; ip_bc_pwm_pilot__map_req__n_page
calls   0Dh, Get_IP_Word_3D_Table
jb      lv_bc_dynm, loc_C43D2
mov     ov_bc_i_term, r4
mov     ov_bc_pilot_prev, r4
jmpr    cc_UC, calculate_p_term

calculate_i_term:
mov     r13, ov_bc_pilot_prev
mov     r12, r4
mov     ov_bc_pilot_prev, r4
calls   0Dh, Signed_Subtraction_Return_Word
mov     r6, r4
mov     r12, #3EA4h ; ldpm_bc_n_address
mov     r13, #1Dh   ; ldpm_bc_n_page
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #1A84h ; ip_bc_pwm_i__n_address
mov     r13, #1Fh   ; ip_bc_pwm_i__n_page
calls   0Dh, Get_IP_Word_2D_Table
mov     r12, r4
mov     r13, ov_bc_ld_err
calls   0Ch, Multiply_And_Shift_Return_Word
mov     r12, r4
mov     r13, r6
calls   0Ch, Signed_Addition_Return_Word
mov     r12, r4
mov     r13, ov_bc_i_term
calls   0Ch, BC_Signed_Addition_Return_Word
mov     r12, r4
calls   0Ch, Check_BC_PID_Limits
mov     ov_bc_i_term, r4

calculate_p_term:
mov     r12, #3EA4h ; ldpm_bc_n_address
mov     r13, #1Dh   ; ldpm_bc_n_page
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #1A6Ch ; ip_bc_pwm_p__n_address
mov     r13, #1Fh   ; ip_bc_pwm_p__n_page
calls   0Dh, Get_IP_Word_2D_Table
mov     r12, r4
mov     r13, ov_bc_ld_err
calls   0Ch, Multiply_And_Shift_Return_Word
mov     ov_bc_p_term, r4

calculate_d_term:
mov     r12, ov_map
mov     r13, ov_map_copy_4
calls   0Dh, Signed_Subtraction_Return_Word
mov     ov_bc_map_grd, r4
mov     r6, r4
mov     r12, #3EA4h ; ldpm_bc_n_address
mov     r13, #1Dh   ; ldpm_bc_n_page
mov     r14, ov_n
calls   0Dh, Get_IP_Word_Y_Axis
mov     r12, #3ED0h ; ldp_bc_map_err_address
mov     r13, #1Dh   ; ldp_bc_map_err_page
mov     r14, ov_bc_abs_err
calls   0Dh, Get_IP_Word_X_Axis
mov     r12, #1A9Ch ; ip_bc_pwm_d__n__map_err_address
mov     r13, #1Fh   ; ip_bc_pwm_d__n__map_err_page
calls   0Dh, Get_IP_Word_3D_Table
mov     r12, r4
mov     r13, r6
calls   0Ch, Multiply_And_Shift_Return_Word
mov     ov_bc_d_term, r4

calculate_pid_output:
mov     r12, #0
mov     r13, r4
calls   0Ch, Signed_Addition_Return_Word
mov     r12, r4
mov     r13, ov_bc_p_term
calls   0Ch, Signed_Addition_Return_Word
mov     r12, r4
mov     r13, ov_bc_i_term
calls   0Ch, Signed_Addition_Return_Word

clamp_output:
mov     r12, r4
calls   0Ch, Check_BC_PID_Limits

set_bc_output:
mov     ov_bc_output, r4

return_from_sub:
rets

BOOST_CONTROLLER ENDS