Lynx Distributor
https://www.victronenergy.com/upload/documents/Lynx_Distributor/24531-Lynx_Distributor_Manual-pdf-en.pdf

I2C device addresses:
DIP off off -> A -> 0x08
DIP on off -> B -> 0x09
DIP off on -> C -> 0x0A
DIP on on -> D -> 0x0B

Fuses from left to right when outlets down (regular Distributor orientation)
Fuse Code when defect:
1 -> 0x10
2 -> 0x20
3 -> 0x40
4 -> 0x80
-> all good: 0x00
-> all defect: 0xF0
-> 1 and 3 defect: 0x50
-> 2 and 4 defect: 0xA0
