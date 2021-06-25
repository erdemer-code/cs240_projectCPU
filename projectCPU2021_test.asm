0: JMP 1 // also JMP Test
1: 3
2: 0 // indirection register

// ADD Test 0 -- Regular
3: JMP 4 // Program Start
4: 7
5: 15
6: 17
7: CP2W 5
8: ADD 6 // 15 + 17 = 32

// ADD Test 1 -- Subtraction
9: JMP 10
10: 13
11: 20
12: 0xFFFC // -4
13: CP2W 11
14: ADD 12 // 20 - 4 = 16 

// NAND Test 0
15: JMP 16
16: 19 
17: 0xFFFF
18: 0xFFFF
19: CP2W 17
20: NAND 18 // 0xFFFF NAND 0xFFFF = 0

// NAND Test 1
21: JMP 22
22: 25
23: 0xFF0B
24: 0XFF0C
25: CP2W 23
26: NAND 24 // 0xFF0B NAND 0x00FC = 0x00F7

// SRRL Test 0 -- Shift Right
27: JMP 28
28: 31
29: 65
30: 3
31:CP2W 29
32: SRRL 30 // 65 >> 3 = 8

// SRRL Test 1 -- Shift Left
33: JMP 34
34: 37
35: 1
36: 23
37: CP2W 35
38: SRRL 36 // 1 << (23 - 16) = 128

// SRRL Test 2 -- Rotate Right
39: JMP 40
40: 43
41: 0xF00D
42: 36
43: CP2W 41
44: SRRL 42 // 0xF00D rrot (36 - 32) = 0xDF00

// SRRL Test 3 -- Rotate Left
45: JMP 46
46: 49
47: 0xBEEF
48: 52
49: CP2W 47
50: SRRL 48 // 0xBEEF lrot (52 - 48) = 0xEEFB

// GE Test 0 -- A < B
51: JMP 52
52: 55
53: 12
54: 15
55: CP2W 53
56: GE 54 // (12 >= 15) = 0

// GE Test 1 -- A > B
57: JMP 58
58: 61
59: 15
60: 12
61: CP2W 59
62: GE 60 // (15 >= 12) = 1

// GE Test 2 -- A = B
63: JMP 64
64: 67
65: 15
66: 15
67: CP2W 65
68: GE 66 // (15 >= 15) = 1

// CP2W and CPfW Test 0
69: JMP 70
70: 73
71: 255
72: 0
73: CP2W 71 // W = 255
74: CPfW 72 // *72 = 255

// SZ Test 0 - Skip
75: JMP 76
76: 78
77: 0
78: SZ 77 // (*78 == 0) = True -> PC = PC + 2 = 80
79: CP2W 200 // Shouldn't execute, it's here incase you don't skip 
200: 0xDEAD

// SZ Test 1 - Don't Skip
80: JMP 82
82: 84
83: 1
84: SZ 83 // (*82 == 0) = False -> PC = PC + 1 = 84
85: JMP 202
86: CP2W 201 // Shouldn't execute, it's here incase you skip
201: 0xDEAD
202: 87

// Indirect Adressing Tests

// ADD Indirect Test
87: JMP 90
90: 94
91: 10
92: 93
93: 6
94: CP2W 92
95: CPfW 2
96: CP2W 91
97: ADD 0 // (**92 + *91) -> (*93 + *91) -> 6 + 10 = 16

// NAND Indirect Test
98: JMP 99
99: 103
100: 0xF0F0
101: 102
102: 0x00F0
103: CP2W 101
104: CPfW 2
105: CP2W 100
106: NAND 0 // (**101 NAND *100) -> (*102 NAND *100) -> 0x00F0 NAND 0xF0F0 = 0xFF0F

// SRRL Indirect Test
107: JMP 108
108: 112
109: 0xC0DE
110: 111
111: 40
112: CP2W 110
113: CPfW 2
114: CP2W 109
115: SRRL 0 // (*109 SRRL **110) -> (*109 SRRL *111) -> 0xCODE rrot (40 - 32) = 0xDECO

// GE Indirect Test
116: JMP 117
117: 121
118: 32
119: 120
120: 16
121: CP2W 119
122: CPfW 2
123: CP2W 118
124: GE 0 // (*118 >= **119) -> (*118 >= *120) -> (32 >= 16) = 1

// SZ Indirect Test
125: JMP 126
126: 129
127: 128
128: 0
129: CP2W 127
130: CPfW 2
131: SZ 0 // (**127 == 0) -> (*128 == 0) -> (0 == 0) = 1 -> PC = PC + 2
132: CP2W 134 // shouldn't execute, it's here in case you don't skip
133: JMP 135
134: 0XDEAD
135: 136

// CP2W Indirect Test
136: JMP 137
137: 140
138: 139
139: 0xFEED
140: CP2W 138
141: CPfW 2
142: CP2W 0 // (W = **138) -> (W = *139) -> W = 0xFEED

// CPfW Indirect Test
143: JMP 144
144: 148
145: 0xDEAF
146: 147
147: 0
148: CP2W 146
149: CPfW 2
150: CP2W 145
151: CPfW 0 // (**146 = *145) -> (*147 = *145) -> *147 = 0xDEAF

// JMP Indirect Test 
152: JMP 153
153: 156
154: 155
155: 158
156: CP2W 154
157: CPfW 2
158: JMP 0 // (goto **154) -> (goto *155) -> goto 158
// will loop to itself and end
