# Cora Z7-10 Development Kit Notes

This repo provides demos using Digilent's Cora-Z7-10 development board.

## Misc Notes

### Console

- The serial console enumerates as /dev/ttyUSB1.
- Launch console via minicom:
```
$ minicom -b115200 -D/dev/ttyUSB1
```
- Make sure to turn off Hardware Flow Control (Ctlr-A Z/cOnfigure Minicom(O)/Serial port setup)

### Linux user/pwd

Login as: root; password=cora
