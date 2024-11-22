check if the kernel config is correct
```bash
cat /boot/config-$(uname -r) | grep CONFIG_*BPF
```

check if the kernel has BTF info
```bash
cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO
```

dump kernel types in from fs
```bash
bpftool btf dump file /sys/kernel/btf/vmlinux format c"
```

