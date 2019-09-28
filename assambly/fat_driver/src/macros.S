/*********************************************************************************
 *                                                                               *
 *                                                                               *
 *    Name       : macros.S                                                      *
 *    Date       : 23-Feb-2014                                                   *
 *    Version    : 0.0.1                                                         *
 *    Source     : assembly language                                             *
 *    Author     : Ashakiran Bhatter                                             *
 *                                                                               *
 *                                                                               *
 *********************************************************************************/
/* predefined macros: boot loader                         */
#define BOOT_LOADER_CODE_AREA_ADDRESS                 0x7c00
#define BOOT_LOADER_CODE_AREA_ADDRESS_OFFSET          0x0000


/* predefined macros: stack segment                       */
#define BOOT_LOADER_STACK_SEGMENT                     0x7c00


#define BOOT_LOADER_ROOT_OFFSET                       0x0200
#define BOOT_LOADER_FAT_OFFSET                        0x0200


#define BOOT_LOADER_STAGE2_ADDRESS                    0x1000
#define BOOT_LOADER_STAGE2_OFFSET                     0x0000 


/* predefined macros: floppy disk layout                  */
#define BOOT_DISK_SECTORS_PER_TRACK                   0x0012
#define BOOT_DISK_HEADS_PER_CYLINDER                  0x0002
#define BOOT_DISK_BYTES_PER_SECTOR                    0x0200
#define BOOT_DISK_SECTORS_PER_CLUSTER                 0x0001


/* predefined macros: file system layout                  */
#define FAT12_FAT_POSITION                            0x0001
#define FAT12_FAT_SIZE                                0x0009
#define FAT12_ROOT_POSITION                           0x0013
#define FAT12_ROOT_SIZE                               0x000e
#define FAT12_ROOT_ENTRIES                            0x00e0
#define FAT12_END_OF_FILE                             0x0ff8


/* predefined macros: boot loader                         */
#define BOOT_SIGNATURE                                0xaa55


/* user-defined macro functions */
/* this macro is used to set the environment */
.macro initEnvironment
     call _initEnvironment
.endm

/* this macro is used to display a string    */
/* onto the screen                           */
/* it calls the function _writeString to     */
/* perform the operation                     */
/* parameter(s): input string                */
.macro writeString message
     pushw \message
     call  _writeString
     addw  $0x02, %sp
.endm

/* this macro is used to read a sector into  */
/* the target memory                         */
/* It calls the _readSector function with    */
/* the following parameters                  */
/* parameter(s): sector Number               */
/*            address to load                */
/*            offset of the address          */
/*            Number of sectors to read      */
.macro readSector sectorno, address, offset, totalsectors
     pushw \sectorno
     pushw \address
     pushw \offset
     pushw \totalsectors
     call  _readSector
     addw  $0x0008, %sp
.endm

/* this macro is used to find a file in the  */
/* FAT formatted drive                       */
/* it calls readSector macro to perform this */
/* activity                                  */
/* parameter(s): root directory position     */
/*               target address              */
/*               target offset               */
/*               root directory size         */
.macro findFile file
     /* read fat table into memory */
     readSector $FAT12_ROOT_POSITION, $BOOT_LOADER_CODE_AREA_ADDRESS, $BOOT_LOADER_ROOT_OFFSET, $FAT12_ROOT_SIZE
     pushw \file
     call  _findFile
     addw  $0x0002, %sp
.endm

/* this macro is used to convert the given   */
/* cluster into a sector number              */
/* it calls _clusterToLinearBlockAddress to  */
/* perform this activity                     */
/* parameter(s): cluster number              */
.macro clusterToLinearBlockAddress cluster
     pushw \cluster
     call  _clusterToLinearBlockAddress
     addw  $0x0002, %sp
.endm

/* this macro is used to load a target file  */
/* into the memory                           */
/* It calls findFile and then loads the data */
/* of the respective file into the memory at */
/* address 0x1000:0x0000                     */
/* parameter(s): target file name            */
.macro loadFile file
     /* check for file existence */
     findFile \file


     pushw %ax
     /* read fat table into memory */
     readSector $FAT12_FAT_POSITION, $BOOT_LOADER_CODE_AREA_ADDRESS, $BOOT_LOADER_FAT_OFFSET, $FAT12_FAT_SIZE


     popw  %ax
     movw  $BOOT_LOADER_STAGE2_OFFSET, %bx
_loadCluster:
     pushw %bx
     pushw %ax

 
     clusterToLinearBlockAddress %ax
     readSector %ax, $BOOT_LOADER_STAGE2_ADDRESS, %bx, $BOOT_DISK_SECTORS_PER_CLUSTER


     popw  %ax
     xorw %dx, %dx
     movw $0x0003, %bx
     mulw %bx
     movw $0x0002, %bx
     divw %bx


     movw $BOOT_LOADER_FAT_OFFSET, %bx
     addw %ax, %bx
     movw $BOOT_LOADER_CODE_AREA_ADDRESS, %ax
     movw %ax, %es
     movw %es:(%bx), %ax
     orw  %dx, %dx
     jz   _even_cluster
_odd_cluster:
     shrw $0x0004, %ax
     jmp  _done 
_even_cluster:
     and $0x0fff, %ax
_done:
     popw %bx
     addw $BOOT_DISK_BYTES_PER_SECTOR, %bx
     cmpw $FAT12_END_OF_FILE, %ax
     jl  _loadCluster


     /* execute kernel */
     initKernel     
.endm

/* parameter(s): target file name            */
/* this macro is used to pass the control of */
/* execution to the loaded file in memory at */
/* address 0x1000:0x0000                     */
/* parameters(s): none                       */
.macro initKernel
     /* initialize the kernel */
     movw  $(BOOT_LOADER_STAGE2_ADDRESS), %ax
     movw  $(BOOT_LOADER_STAGE2_OFFSET) , %bx
     movw  %ax, %es
     movw  %ax, %ds
     jmp   $(BOOT_LOADER_STAGE2_ADDRESS), $(BOOT_LOADER_STAGE2_OFFSET)
.endm
