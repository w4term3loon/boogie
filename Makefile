MAKEFILE_DIR=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CLANG=clang
BPFTOOL=bpftool
CFLAGS=-g -O2 -Wall -Wextra

all: trace
.PHONY: all

vmlinux.h:
	$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

trace.bpf.c: vmlinux.h
.PHONY: trace.bpf.c

trace.bpf.o: trace.bpf.c
	$(CLANG) $(CFLAGS) -target bpf -D__TARGET_ARCH_x86_64 -Ideps/libbpf/src -c trace.bpf.c -o trace.bpf.o

trace.skel.h: trace.bpf.o
	$(BPFTOOL) gen skeleton trace.bpf.o > trace.skel.h

trace.c: trace.skel.h
.PHONY: trace.c

trace.o: trace.c
	$(CLANG) $(CFLAGS) -I $(MAKEFILE_DIR) -c trace.c -o trace.o

trace: trace.o
	$(CLANG) $(CFLAGS) trace.o deps/libbpf/src/build/libbpf.a -lelf -lz -o trace

clean:
	rm trace trace.o trace.skel.h trace.bpf.o vmlinux.h
.PHONY: clean

libbpf:
	if [ ! -e deps/libbpf ] ; then git clone --branch v1.5.0 --depth 1 https://github.com/libbpf/libbpf ./deps/libbpf ; fi
	cd deps/libbpf/src && mkdir -p build
	BUILD_STATIC_ONLY=y OBJDIR=build $(MAKE) -C deps/libbpf/src
.PHONY: libbpf

clean-deps:
	rm -rf deps

# apt packages
apt-packs:
	apt install build-essential clang flex bison libbpf-dev
.PHONY: apt-packs

