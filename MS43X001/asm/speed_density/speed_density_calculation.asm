RAM_DATA SECTION DATA

ov_ve           DSW 1
ov_n            DSW 1
ov_map          DSW 1
ov_maf_ti_kgh   DSW 1
ov_maf_tco_cor  DSW 1
ov_maf_ti       DSW 1
ov_tia          DS 1

RAM_DATA ENDS


CAL_DATA SECTION CONST

c_eng_disp      DW 0xBEA

CAL_DATA ENDS


SPEED_DENSITY_CALCULATION SECTION CODE
; ov_maf_kgh = (0.046234 * ov_n * ov_cyl_vol * ov_ve * (ov_map / 10)) / (273.15 + ov_tia)

; c_eng_disp * ov_ve
mov     r12, c_eng_disp
mov     r13, ov_ve
mov     r14, #400h
calls   9, Divide_DWord_Return_DWord_With_Bounds_Check
mov     r6, r4

; 0.046234 * ov_n
mov     r12, ov_n
mov     r13, #5EBh      ; Ideal Gas constant + Air Mol mass + datatype conversion factor
mov     r14, #8000h
calls   9, Divide_DWord_Return_DWord_With_Bounds_Check
mov     r7, r4

; ov_map / 10
mov     r12, ov_map
mov     r13, ZEROS
mov     r14, #0Ah
calls   0Dh, Divide_DWord_Return_DWord_With_Bounds_Check
mov     r12, r5
mov     r13, r6
mov     r14, #400h
calls   9, Divide_DWord_Return_DWord_With_Bounds_Check

; (ov_n * ov_cyl_vol) * ov_map_kpa
mov     r12, r4
mov     r13, r7
mulu    r12, r13
mov     r12, MDL
mov     r13, MDH

; 273.15 + ov_tia
movbz   r14, ov_tia
add     r14, #12Ch      ; Kelvin constant

; ov_map_kpa_mul / ov_tia_kelvin
calls   0Dh, Divide_DWord_Return_DWord_With_Bounds_Check
mov     ov_maf_ti_kgh, r5

; ov_maf_ti_kgh => ov_maf_ti
shr     r5, #1
mov     r12, r5
mov     r13, ov_n
calls   0Dh, Divide_Word_Return_Word_With_Bounds_Check

; ov_maf_ti * ov_maf_tco_cor
mov     r12, r4
mov     r4, #100h
movbz   r13, ov_maf_tco_cor
mul     r13, r4
mov     r13, MDL
calls   0Dh, Multiply_By_Factor_Return_Word
mov     ov_maf_ti, r4

SPEED_DENSITY_CALCULATION ENDS