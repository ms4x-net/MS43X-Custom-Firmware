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


IGN_CUT SECTION CODE
check_ign_cut_feature_active:
jb      lv_n_lim_etc_mon, fuel_cut_n_max ; If ETC limp home mode is active fall back to the standard fuel cut engine speed limiter

movb    rl4, c_conf_n_max
jmpr    cc_NZ, ign_cut_n_max ; Jump to the ignition cut engine speed limiter if c_conf_n_max is not zero else use the standard fuel cut engine speed limiter

fuel_cut_n_max:
jmps    Fuel_Cut_Engine_Speed_Limiter

ign_cut_n_max:
jb      lv_n_max, check_disable_treshold ; Jump to the de-activation checks if the engine speed limiter is already active

check_enable_treshold: ; Check if the current engine speed is above the engine speed limiter activation threshold
movb    rl4, ov_n_32
cmpb    rl4, ov_n_max_av
jmpr    cc_C, return_from_sub
bset    lv_n_max ; Start signaling that the engine speed limiter is active
bset    lv_ign_cut ; Enable ignition cut
jmpr    cc_UC, delay_engine_roughness

check_disable_treshold: ; Check if the current engine speed is below the engine speed limiter deactivation threshold
movb    rl4, ov_n_32
cmpb    rl4, ov_n_max_hys_max
jmpr    cc_NC, delay_engine_roughness
bclr    lv_n_max ; Stop signaling that the engine speed limiter is active
bclr    lv_ign_cut ; Disable ignition cut
jmp     cc_UC, return_from_sub

delay_engine_roughness:
mov     r6, #64h ; Delay engine roughness detection for 1 second
mov     ov_dly_er, r6
bset    lv_dly_er ; Activate engine roughness detection delay

return_from_sub:
rets

IGN_CUT ENDS