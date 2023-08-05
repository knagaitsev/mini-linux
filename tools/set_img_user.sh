#!/bin/bash

# sudo apt install libguestfs-tools
sudo virt-customize -a ubuntu.img --root-password password:pass
