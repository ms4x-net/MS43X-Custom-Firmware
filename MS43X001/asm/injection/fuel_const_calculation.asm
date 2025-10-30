RAM_DATA SECTION DATA

ov_ff_fac_ti    DS 1
ov_af_stoich    DS 1
ov_fuel_const   DSW 1

RAM_DATA ENDS

CAL_DATA SECTION CONST

c_af_stoich_ron98       DB 0x93
c_af_stoich_e85         DB 0x62
c_fuel_density_ron98    DW 0x5C29
c_fuel_density_e85      DW 0x628F
c_inj_flow              DW 0x0110

CAL_DATA ENDS

FUEL_CONST_CALC SECTION CODE
; ov_fuel_const = ((c_inj_flow * ov_af_stoich) / 10) * ov_fuel_density

; ov_af_stoich = c_af_stoich_ron98 + (c_af_stoich_e85 - c_af_stoich_ron98) * ov_ff_fac_ti
movbz   r13, c_af_stoich_ron98
movbs   r14, ov_ff_fac_ti
movbz   r12, c_af_stoich_e85
calls   0Dh, Blend_Values_Return_Word
movb    ov_af_stoich, rl4

; af_inj_flow = (c_inj_flow * ov_af_stoich) / 10
mov     r13, r4
mov     r12, c_inj_flow
mov     r14, #0Ah
calls   0Bh, Multiply_And_Divide_Return_Word
mov     [-r0], r4

; fuel_density = c_fuel_density_ron98 + (c_fuel_density_e85 - c_fuel_density_ron98) * ov_ff_fac_ti
mov     r13, c_fuel_density_ron98
movbs   r14, ov_ff_fac_ti
mov     r12, c_fuel_density_e85
calls   0Dh, Blend_Values_Return_Word

; ov_fuel_const = af_inj_flow * fuel_density
mov     r13, r4
mov     r12, [r0+]
calls   0Dh, Multiply_By_Factor_Return_Word
mov     ov_fuel_const, r4
rets

FUEL_CONST_CALC ENDS