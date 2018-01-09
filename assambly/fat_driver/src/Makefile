.SILENT:
CC                = gcc
LD                = ld
OBJCOPY           = objcopy
CFLAGS            = -c -Wall -Werror
TRIM_FLAGS        = -R .pdr -R .comment -R.note -S -O binary
LDFILE_STAGE0     = stage0.ld
LDFLAGS_STAGE0    = -T$(LDFILE_STAGE0)
LINUX_FILE_FORMAT = elf
DD                = dd
BOOT              = stage0
KERNEL            = kernel
REDIRECT          = > /dev/null 2>&1

clean:
	@echo "removing temp files now...."
	@rm -rf ../bin/*.o
	@rm -rf ../bin/*.elf
	@rm -rf ../bin/*.bin
	@rm -rf ../iso/*.img
	@rm -rf ../iso/tmp-loop
	@echo "     Done..."

compile:
	@echo "building modules..."
	@$(CC) $(CFLAGS) $(BOOT).S -o ../bin/$(BOOT).o
	@$(LD) ../bin/$(BOOT).o -o ../bin/$(BOOT).$(LINUX_FILE_FORMAT) $(LDFLAGS_STAGE0)
	@$(OBJCOPY) $(TRIM_FLAGS) ../bin/$(BOOT).$(LINUX_FILE_FORMAT) ../bin/$(BOOT).bin
	@$(CC) -std=c99 -c -g -Os -march=86_64 -ffreestanding -Wall -Werror ../kernel/$(KERNEL).c -o ../bin/$(KERNEL).o
	@$(LD) -static -T ../kernel/$(KERNEL).ld -nostdlib --nmagic -o ../bin/$(KERNEL).elf ../bin/$(KERNEL).o
	@$(OBJCOPY) -O binary ../bin/$(KERNEL).elf ../bin/$(KERNEL).bin
	@echo "     Done..."

image:
	@echo "creating boot image..."
	@dd if=../bin/$(BOOT).bin of=../iso/$(BOOT).img bs=512 count=1 $(REDIRECT)
	@dd if=/dev/zero of=../iso/$(BOOT).img skip=1 seek=1 bs=512 count=2879 $(REDIRECT)
	@echo "     Done..."

setup:
	@echo "setting up the environment..."
	@mkdir -p ../iso/tmp-loop;
	@mount -o loop ../iso/$(BOOT).img ../iso/tmp-loop/ -o fat=12;
	@cp ../bin/$(KERNEL).bin ../iso/tmp-loop/;
	@umount ../iso/tmp-loop/;
	@rm -rf ../iso/tmp-loop/;
	@echo "     Done..."

test:
	@echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	make clean
	make compile
	make image
	make setup
	@echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
