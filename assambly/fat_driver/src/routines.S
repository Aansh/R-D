/*********************************************************************************
 *                                                                               *
 *                                                                               *
 *    Name       : routines.S                                                    *
 *    Date       : 23-Feb-2014                                                   *
 *    Version    : 0.0.1                                                         *
 *    Source     : assembly language                                             *
 *    Author     : Ashakiran Bhatter                                             *
 *                                                                               *
 *                                                                               *
 *********************************************************************************/
/* user-defined routines */
/* this function is used to set-up the */
/* registers and stack as required     */
/* parameter(s): none                  */
_initEnvironment:
     pushw %bp
     movw  %sp, %bp
_initEnvironmentIn:
     cli
     movw  %cs, %ax
     movw  %ax, %ds
     movw  %ax, %es
     movw  %ax, %ss
     movw  $BOOT_LOADER_STACK_SEGMENT, %sp
     sti
_initEnvironmentOut:
     movw  %bp, %sp
     popw  %bp
ret

/* this function is used to display a string */
/* onto the screen                           */
/* parameter(s): input string                */
_writeString:
     pushw %bp
     movw  %sp   , %bp
     movw 4(%bp) , %si
     jmp  _writeStringCheckByte
_writeStringIn:
     movb $0x000e, %ah
     movb $0x0000, %bh
     int  $0x0010
     incw %si
_writeStringCheckByte:
     movb (%si)  , %al
     orb  %al    , %al
     jnz  _writeStringIn
_writeStringOut:
     movw %bp    , %sp
     popw %bp
ret

/* this function is used to read a sector    */
/* into the target memory                    */
/* parameter(s): sector Number               */
/*            address to load                */
/*            offset of the address          */
/*            Number of sectors to read      */
_readSector:
     pushw %bp
     movw %sp    , %bp

     movw 10(%bp), %ax
     movw $BOOT_DISK_SECTORS_PER_TRACK, %bx
     xorw %dx    , %dx
     divw %bx

     incw %dx
     movb %dl    , %cl

     movw $BOOT_DISK_HEADS_PER_CYLINDER, %bx
     xorw %dx    , %dx
     divw %bx

     movb %al    , %ch
     xchg %dl    , %dh

     movb $0x02  , %ah
     movb 4(%bp) , %al
     movb bootDrive, %dl
     movw 8(%bp) , %bx
     movw %bx    , %es
     movw 6(%bp) , %bx
     int  $0x13
     jc   _abort
     cmpb 4(%bp) , %al
     jc   _abort

     movw %bp    , %sp
     popw %bp
ret

/* this function is used to find a file in   */
/* the FAT formatted drive                   */
/* parameter(s): root directory position     */
/*               target address              */
/*               target offset               */
/*               root directory size         */
_findFile:
     pushw %bp
     movw  %sp   , %bp

     movw  $BOOT_LOADER_CODE_AREA_ADDRESS, %ax
     movw  %ax   , %es
     movw  $BOOT_LOADER_ROOT_OFFSET, %bx
     movw  $FAT12_ROOT_ENTRIES, %dx
     jmp   _findFileInitValues

_findFileIn:
     movw  $0x000b  , %cx
     movw  4(%bp)   , %si
     leaw  (%bx)    , %di
     repe  cmpsb
     je    _findFileOut
_findFileDecrementCount:
     decw  %dx
     addw  $0x0020, %bx
_findFileInitValues:
     cmpw  $0x0000, %dx
     jne   _findFileIn
     je    _abort
_findFileOut:
     addw  $0x001a  , %bx
     movw  %es:(%bx), %ax
     movw  %bp, %sp
     popw  %bp
ret

/* this function is used to convert the given*/
/* cluster into a sector number              */
/* parameter(s): cluster number              */
_clusterToLinearBlockAddress:
     pushw %bp
     movw  %sp    , %bp
     movw  4(%bp) , %ax
_clusterToLinearBlockAddressIn:
     subw  $0x0002, %ax
     movw  $BOOT_DISK_SECTORS_PER_CLUSTER, %cx
     mulw  %cx
     addw  $FAT12_ROOT_POSITION, %ax
     addw  $FAT12_ROOT_SIZE, %ax
_clusterToLinearBlockAddressOut:
     movw  %bp    , %sp
     popw  %bp
ret
