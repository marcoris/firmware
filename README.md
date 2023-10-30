# Firmware maker v0.0.1
This will build firmware with linux kernel v6.5.3 and busybox v1.36.1. 
All you have to do is to set the versions and run the `make_firmware.sh` script.

## Needed stuff on an ubuntu machine
```bash
sudo apt update \
sudo apt install make qemu-system git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison -y \
scripts/config --disable SYSTEM_TRUSTED_KEYS \
scripts/config --disable SYSTEM_REVOCATION_KEYS
```

## Running the script
```bash
./make_firmware.sh
```
