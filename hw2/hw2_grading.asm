.data

.align 2
__checksum_valid1: .word
0x4500001F, 0x00000000, 0x00009108, 0xABCDEF12, 0xFEED9009, 0x61616161, 0x61616161, 0x616161FF

.align 2
__checksum_valid2: .word
0x45FFFFFF, 0xEFEFEFEF,  0xEEEE2E55, 0xDDEDEFEF, 0xFEFFEFFE, 0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC

.align 2
__checksum_invalid1: .word
0x75FF0113, 0xFFEECCBB, 0xABBAbcde, 0x00987d54, 0x3210ABCD, 0x11112222, 0x33334444, 0x55556666, 0x77778888

.align 2
__checksum_invalid2: .word
0x65001234,0x87654321,0xABCDac10,0xEEEE122,0x33221100,0xAAAABBBB,0xCCCCDDDD,0xEEEEFFFF


.align 2
array1: .word
0x4500001F,0x00000000,0x00009108,0xABCDEF12,0xFEED9009
.ascii "aaaaaaaaaaa!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"



.align 2
array2:
.word
0x45000020,0x00000000,0x00009107,0xABCDEF12,0xFEED9009
.ascii "aaaaaaaaaaaa!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
.word 0x4500001D,0x0000800C,0x00115FF4,0x0987AD6E,0xFFC82412
.ascii "bbbbbbbbb@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
.word 0x45000018,0x00008015,0x000010FA,0xABCDEF12,0xFEED9009
.ascii "cccc************************************"
.word 0x45000028,0x00008019,0x1234FEB1,0xABCDEF12,0xFEED9009
.ascii "dddddddddddddddddddd--------------------"

.align 2
array3:
.word 0x45210037,0xccdd8018,0xffaac20b,0x82f5ba0a,0x0a3264c8
.ascii "We are the curious\nThe explorers. T~~~~~"
.word 0x4521003B,0xccdd8018,0xffaac207,0x82f5ba0a,0x0a3264c8
.ascii "he innovators. Unbound by tradition, un!"
.word 0x4521003B,0xccdd8018,0xffaac207,0x82f5ba0a,0x0a3264c8
.ascii "limited in our potential\npropelled by a@"
.word 0x45210031,0xccdd8018,0xffaac211,0x82f5ba0a,0x0a3264c8
.ascii" vision of a bold new future.???????????"
.word 0x4521001B,0xccdd8018,0xffaac227,0x82f5ba0a,0x0a3264c8
.ascii " We are^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
.word 0x45210038,0xccdd8018,0xffaac20a,0x82f5ba0a,0x0a3264c8
.ascii " passionately engaged in the issues &&&&"
.word 0x4521003B,0xccdd8018,0xffaac207,0x82f5ba0a,0x0a3264c8
.ascii "of our time.\nWe emerge from Stony Brook*"
.word 0x45210035,0xccdd8018,0xffaac20d,0x82f5ba0a,0x0a3264c8
.ascii " with the momentum to make a REAL((((((("
.word 0x4521003C,0xccdd8018,0xffaac206,0x82f5ba0a,0x0a3264c8
.ascii " difference.\nOur spirit is empowered by "
.word 0x45210037,0xccdd8018,0xffaac20b,0x82f5ba0a,0x0a3264c8
.ascii "who we are and what we've learned\nI)))))"
.word 0x45210031,0xccdd8018,0xffaac211,0x82f5ba0a,0x0a3264c8
.ascii "t drives us in pursuit of the..........."
.word 0x45210034,0xccdd8018,0xffaac20e,0x82f5ba0a,0x0a3264c8
.ascii " BIG IDEAS that will transform o????????"
.word 0x4521003A,0xccdd8018,0xffaac208,0x82f5ba0a,0x0a3264c8
.ascii "ur lives and impact our world.\nWE ARE '"
.word 0x4521002C,0xccdd8018,0xffaac216,0x82f5ba0a,0x0a3264c8
.ascii "STONY\nBROOK\nUNIVERSITY.\n>>>>>>>>>>>>>>>"
.word 0x45210031,0xccdd8018,0xffaac211,0x82f5ba0a,0x0a3264c8
.ascii " We reach across boundaries.\n$$$$$$$$$$$"
.word 0x45210034,0xccdd8018,0xffaac20e,0x82f5ba0a,0x0a3264c8
.ascii " We break through expectations.\n--------"
.word 0x45210024,0xccdd8018,0xffaac21e,0x82f5ba0a,0x0a3264c8
.ascii "We go\nFAR\nBEYOND++++++++++++++++++++++++"


.align 2
#msg: .asciiz "Stony Brook\nHome of the\nSeawolves!\nHuzzah!?????????"

H: .asciiz "Home of the\nSeawolves!\nHuzzah!?????????"

backslashN: .asciiz "\nHuzzah!?????????"


array2b:
.word 0x45000020,0x00000000,0x00009107,0xABCDEF12,0xFEED9009
.ascii "aaaaaaaaaaaa!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
.word 0x4500001D,0x0000800C,0x00115FF4,0x0987AD6E,0xFFC82412
.ascii "bbbbbbbbb@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
.word 0x45000018,0x00008015,0x000010FA,0xABCDEF12,0xFEED9009
.ascii "cccc************************************"
.word 0x45000028,0x00008019,0x1234FEB1,0xABCDEF12,0xFEED9009
.ascii "dddddddddddddddddddd--------------------"
.space 40


.align 2
#array2_pkt0 - checksum error in packet 0
array2c: 
.word  0x45000020,0xFF000000, 0x00009107,0xABCDEF12,0xFEED9009,0x61616161,0x61616161,0x61616161,0x43434343,0x43434343,0x43434343,0x43434343,0x43434343,0x43434343,0x43434343
.word 0x4500001D,0x0000800C,0x00115FF4,0x0987ADE,0xFFC82412,0x62626262,0x62626262,0x625E5E5E,0x5E5E5E5E,0x5E5E5E5E,0x5E5E5E5E,0x5E5E5E5E,0x5E5E5E5E,0x5E5E5E5E,0x5E5E5E5E
.word 0x45000018,0x00008015,0x000010FA,0xABCDEF12,0xFEED9009,0x63636363,0x35353535,0x35353535,0x35353535,0x35353535,0x35353535,0x35353535,0x35353535,0x35353535,0x35353535
.word 0x45000028,0x00008019,0x1234FEB1,0xABCDEF12,0xFEED9009,0x64646464,0x64646464,0x64646464,0x64646464,0x64646464,0x33333333,0x33333333,0x33333333,0x33333333,0x33333333