include(__link__.m4)

#ifndef __APU_H__
#define __APU_H__

#include <arch.h>
#include <stdint.h>
#include <stddef.h>

// Defines

#define APU_STATUS_BUSY   __IO_APU_STATUS_BUSY
#define APU_STATUS_SIGN   __IO_APU_STATUS_SIGN
#define APU_STATUS_ZERO   __IO_APU_STATUS_ZERO
#define APU_STATUS_DIV0   __IO_APU_STATUS_DIV0
#define APU_STATUS_NEGRT  __IO_APU_STATUS_NEGRT
#define APU_STATUS_UNDFL  __IO_APU_STATUS_UNDFL
#define APU_STATUS_OVRFL  __IO_APU_STATUS_OVRFL
#define APU_STATUS_CARRY  __IO_APU_STATUS_CARRY

#define APU_STATUS_ERROR  __IO_APU_STATUS_ERROR

#define APU_OP_ENT   __IO_APU_OP_ENT
#define APU_OP_REM   __IO_APU_OP_REM
#define APU_OP_ENT16 __IO_APU_OP_ENT16
#define APU_OP_ENT32 __IO_APU_OP_ENT32
#define APU_OP_REM16 __IO_APU_OP_REM16
#define APU_OP_REM32 __IO_APU_OP_REM32

#define APU_OP_SADD  __IO_APU_OP_SADD
#define APU_OP_SSUB  __IO_APU_OP_SSUB
#define APU_OP_SMUL  __IO_APU_OP_SMUL
#define APU_OP_SMUU  __IO_APU_OP_SMUU
#define APU_OP_SDIV  __IO_APU_OP_SDIV

#define APU_OP_DADD  __IO_APU_OP_DADD
#define APU_OP_DSUB  __IO_APU_OP_DSUB
#define APU_OP_DMUL  __IO_APU_OP_DMUL
#define APU_OP_DMUU  __IO_APU_OP_DMUU
#define APU_OP_DDIV  __IO_APU_OP_DDIV

#define APU_OP_FADD  __IO_APU_OP_FADD
#define APU_OP_FSUB  __IO_APU_OP_FSUB
#define APU_OP_FMUL  __IO_APU_OP_FMUL
#define APU_OP_FDIV  __IO_APU_OP_FDIV

#define APU_OP_SQRT  __IO_APU_OP_SQRT
#define APU_OP_SIN   __IO_APU_OP_SIN
#define APU_OP_COS   __IO_APU_OP_COS
#define APU_OP_TAN   __IO_APU_OP_TAN
#define APU_OP_ASIN  __IO_APU_OP_ASIN
#define APU_OP_ACOS  __IO_APU_OP_ACOS
#define APU_OP_ATAN  __IO_APU_OP_ATAN
#define APU_OP_LOG   __IO_APU_OP_LOG
#define APU_OP_LN    __IO_APU_OP_LN
#define APU_OP_EXP   __IO_APU_OP_EXP
#define APU_OP_PWR   __IO_APU_OP_PWR

#define APU_OP_NOP   __IO_APU_OP_NOP
#define APU_OP_FIXS  __IO_APU_OP_FIXS
#define APU_OP_FIXD  __IO_APU_OP_FIXD
#define APU_OP_FLTS  __IO_APU_OP_FLTS
#define APU_OP_FLTD  __IO_APU_OP_FLTD
#define APU_OP_CHSS  __IO_APU_OP_CHSS
#define APU_OP_CHSD  __IO_APU_OP_CHSD
#define APU_OP_PTOS  __IO_APU_OP_PTOS
#define APU_OP_PTOD  __IO_APU_OP_PTOD
#define APU_OP_PTOF  __IO_APU_OP_PTOF
#define APU_OP_POPS  __IO_APU_OP_POPS
#define APU_OP_POPD  __IO_APU_OP_POPD
#define APU_OP_POPF  __IO_APU_OP_POPF
#define APU_OP_XCHS  __IO_APU_OP_XCHS
#define APU_OP_XCHD  __IO_APU_OP_XCHD
#define APU_OP_XCHF  __IO_APU_OP_XCHF
#define APU_OP_PUPI  __IO_APU_OP_PUPI

// Data Structures


// Functions

__OPROTO(`a,b,c,d,e,iyh,iyl',`a,b,c,d,e,iyh,iyl',void,,apu_reset,void *int_addr)
__DPROTO(`b,c,d,e,iyh,iyl',`b,c,d,e,iyh,iyl',void,,apu_cmd_ld,void *op_addr,uint8_t command)
__OPROTO(`b,c,d,e,iyh,iyl',`b,c,d,e,iyh,iyl',uint8_t,,apu_chk_idle,void)
__OPROTO(`a,b,c,d,e,h,l,iyh,iyl',`a,b,c,d,e,h,l,iyh,iyl',void,,apu_isr,void)

#endif