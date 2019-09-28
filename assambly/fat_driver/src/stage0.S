/*********************************************************************************
 *                                                                               *
 *                                                                               *
 *    Name       : stage0.S                                                      *
 *    Date       : 23-Feb-2014                                                   *
 *    Version    : 0.0.1                                                         *
 *    Source     : assembly language                                             *
 *    Author     : Ashakiran Bhatter                                             *
 *                                                                               *
 *    Description: The main logic involves scanning for kernel.bin file on a     *
 *                 fat12 formatted floppy disk and then pass the control to it   *
 *                 for its execution                                             *
 *                                                                               *
 *                                                                               *
 *********************************************************************************/
.code16
.text
.globl _start;
_start:
     jmp _boot
     nop
     /*bios parameter block                             description of each entity             value          datatype            width(in bytes) */
     /*--------------------                             --------------------------             -----          --------            --------------- */
     .byte 0x6b,0x69,0x72,0x55,0x58,0x30,0x2e,0x31      /* oem label                         : kirUX0.1     , type: string      , length:    8    */
     .byte 0x00,0x02                                    /* total bytes per sector            : 512          , type: word        , length:    4    */
     .byte 0x01                                         /* total sectors per cluster         : 1            , type: byte        , length:    1    */
     .byte 0x01,0x00                                    /* total reserved sectors            : 1            , type: word        , length:    4    */
     .byte 0x02                                         /* total fat tables                  : 2            , type: byte        , length:    1    */
     .byte 0xe0,0x00                                    /* total directory entries           : 224          , type: word        , length:    4    */
     .byte 0x40,0x0b                                    /* total sectors                     : 2880         , type: word        , length:    4    */
     .byte 0xf0                                         /* media description                 : 0xf0         , type: byte        , length:    1    */
     .byte 0x09,0x00                                    /* size in sectors of each fat table : 9            , type: word        , length:    4    */
     .byte 0x02,0x01                                    /* total sectors per track           : 18           , type: word        , length:    4    */
     .byte 0x02,0x00                                    /* total heads per cylinder          : 2            , type: word        , length:    4    */
     .byte 0x00,0x00, 0x00, 0x00                        /* total hidden sectors              : 0            , type: double word , length:    4    */
     .byte 0x00,0x00, 0x00, 0x00                        /* total big sectors                 : 0            , type: double word , length:    4    */
     .byte 0x00                                         /* boot drive identifier             : 0            , type: byte        , length:    4    */
     .byte 0x00                                         /* total unused sectors              : 0            , type: byte        , length:    4    */
     .byte 0x29                                         /* external boot signature           : 0x29         , type: byte        , length:    4    */
     .byte 0x22,0x62,0x79,0x20                          /* serial number                     : "by          , type: string      , length:    4    */
     .byte 0x41,0x53,0x48,0x41,0x4b,0x49                /* volume label first 6 bytes of 11  : ASHAKI       , type: string      , length:    6    */
     .byte 0x52,0x41,0x4e,0x20,0x42                     /* volume label second 5 bytes of 11 : RAN B        , type: string      , length:    5    */
     .byte 0x48,0x41,0x54,0x54,0x45,0x52,0x22           /* file system type                  : HATTER"      , type: string      , length:    8    */

     /* include macro functions */
     #include "macros.S"

/* begining of main code */
_boot:
     /* initialize the environment */
     initEnvironment 

     /* load stage2 */
     loadFile $fileStage2


/* infinite loop */
_freeze:
     jmp _freeze

/* abnormal termination of program */
_abort:
     writeString $msgAbort
     jmp _freeze

     /* include functions */
     #include "routines.S"

     /* user-defined variables */
     bootDrive : .byte 0x0000
     msgAbort  : .asciz "* * * F A T A L  E R R O R * * *"
     #fileStage2: .ascii "STAGE2  BIN"
     fileStage2: .ascii  "KERNEL  BIN"
     clusterID : .word 0x0000

     /* traverse 510 bytes from beginning */
     . = _start + 0x01fe

     /* append boot signature             */
     .word BOOT_SIGNATURE
