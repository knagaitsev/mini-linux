# source: https://github.com/google/syzkaller/blob/master/docs/syzbot.md

qemu-system-x86_64 -smp 2 -m 4G -enable-kvm -cpu host \
    -net nic -net user,hostfwd=tcp::10022-:22 \
    -kernel build/arch/x86/boot/bzImage -nographic \
    -device virtio-scsi-pci,id=scsi \
    -device scsi-hd,bus=scsi.0,drive=d0 \
    -drive file=stretch-amd64.img,format=raw,if=none,id=d0 \
    -append "root=/dev/sda console=ttyS0 earlyprintk=serial"
