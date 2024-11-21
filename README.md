# Checks
check if the kernel config is correct
"cat /boot/config-$(uname -r) | grep CONFIG_*BPF"
check if the kernel has BTF info
"cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO"

# Info
dump kernel types in from fs
"bpftool btf dump file /sys/kernel/btf/vmlinux format c"

