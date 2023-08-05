CC=gcc
ARCH=x86_64

# configure your linux!
LINUX_VERSION=6.2
LINUX_DIR=linux-$(LINUX_VERSION)
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.2.tar.xz

.PHONY: linux run

# arguments to make
MARGS=CC=$(CC) ARCH=$(ARCH) O=$(PWD)/build --no-print-directory

build/linux_tag:
	@mkdir -p build
	@[ ! -d $(LINUX_DIR) ] && wget -c $(LINUX_URL) -O - | tar -Jx || true
	@$(MAKE) $(MARGS) -C $(LINUX_DIR) defconfig
	touch build/linux_tag


root/main: user/main.c
	gcc -static -o $@ $^

menuconfig: build/linux_tag
	@$(MAKE) $(MARGS) -C $(LINUX_DIR) menuconfig



linux: build/linux_tag
	@$(MAKE) $(MARGS) -C $(LINUX_DIR)


PWD := $(CURDIR)

kmod: linux
	$(MAKE) $(MARGS) -C $(PWD)/build M=$(PWD)/module modules 
	@mkdir -p root/etc/
	@cp module/mod.ko root/etc/
 
clean: 
	$(MAKE) $(MARGS) -C $(PWD)/build M=$(PWD)/module clean

run:
	@tools/run.sh
