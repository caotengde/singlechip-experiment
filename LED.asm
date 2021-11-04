DX EQU P0.0	;移位寄存器串行行输入口Dx
CKX EQU P0.1	;SRCK移位寄存器x方向时钟输入
CKXL EQU P0.2	;RCK存储器x方向时钟输入
ENX EQU P0.7	;存储器x方向使能端口

DY EQU P0.3	;移位寄存器串行列输入口Dy
CKY EQU P0.5	;SRCK移位寄存器y方向时钟输入
CKYL EQU P0.6	;RCK存储器y方向时钟输入
ENY EQU P0.4	;存储器y方向使能端口

PTR EQU R5
BPTR EQU R4	;偏移

ORG 0000H
	LJMP START
ORG 0040H

LEDTABLE:
DB 0FFH ,0FFH ,0FFH ,0EFH ,0FFH ,06FH ,0FFH ,06FH ,0FFH ,05BH ,0F9H ,043H ,0F6H ,0BFH ,0BEH ,0F7H;
DB 080H ,0F7H ,0FDH ,02FH ,0FDH ,0CFH ,0EFH ,037H ,0FFH ,07BH ,0FFH ,0F9H ,0FFH ,0F1H ,0FFH ,0FFH;"我",0
DB 0FFH ,0FFH ,0FFH ,0FFH ,0FBH ,0BFH ,0FAH ,067H ,0F9H ,0FFH ,080H ,037H ,0F6H ,0FBH ,0FBH ,0FBH;
DB 0E0H ,00DH ,0EAH ,0BDH ,0EFH ,0BDH ,0EFH ,0B3H ,0E0H ,07BH ,0FFH ,0EFH ,0FFH ,0EFH ,0FFH ,0FFH;"想",1
DB 0FFH ,0FFH ,0F8H ,0FFH ,0FBH ,07FH ,0FBH ,07FH ,0F0H ,07FH ,0FBH ,0FFH ,0FFH ,0FFH ,0F9H ,067H;
DB 0F7H ,01BH ,08AH ,07BH ,0FAH ,0FDH ,0F7H ,0FDH ,0F7H ,0F9H ,0FFH ,0FBH ,0FFH ,0E3H ,0FFH ,0FFH;"吃",2
DB 0FFH ,0FFH ,0FFH ,07FH ,0FCH ,0FFH ,0F2H ,083H ,0CAH ,06FH ,0FBH ,0EBH ,0FBH ,0F7H ,0F3H ,08FH;
DB 0F0H ,07FH ,0F6H ,037H ,0EEH ,0CFH ,0CDH ,00FH ,0FEH ,0F7H ,0FFH ,0F3H ,0FFH ,0FBH ,0FFH ,0FBH;"饭",3
DB 0FFH ,0FFH ,0FFH ,0EFH ,0FFH ,06FH ,0FFH ,06FH ,0FFH ,05BH ,0F9H ,043H ,0F6H ,0BFH ,0BEH ,0F7H;
DB 080H ,0F7H ,0FDH ,02FH ,0FDH ,0CFH ,0EFH ,037H ,0FFH ,07BH ,0FFH ,0F9H ,0FFH ,0F1H ,0FFH ,0FFH;"我",0
;第一个字需要重复，否则会因为字符表偏移到末尾时有溢出，导致显示不正确


;led显示屏方向
;    U4  U3  (Y)
;U2  L3  L4
;U1  L1  L2
;(X)

START:
	MOV DPTR, #LEDTABLE
	MOV BPTR, #0		;整体左移偏移
	MOV PTR, #0		;16x16字符表偏移
	MOV R3, #5		;R3为控制每次铺满整个屏幕后停顿的帧数（即重复将当前屏幕重复填充R3次）
	
LP:
	MOV R7, #8		;循环计数
	MOV R2, #1		;x控制哪一列可以亮（每次只能点亮一列）
SSS1:				;因后先输入0后R2的原因，实际上是点亮L1和L2
	MOV A, R2
	MOV R0, A		
	MOV R1, #0
	
	ACALL XSHIFTOUT		;X输出(控制哪一行可以亮，L1L2或L3L4)
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R1, A		;R1存入L1显示数据
	
	INC PTR			;偏移自加
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R0, A		;R0存入L2显示数据

	ACALL YSHIFTOUT		;Y输出(控制X指定的那一行怎么亮)
	
	ACALL DELAY		;延迟
	
	INC PTR			;偏移自加
	
	MOV A, R2
	RL A
	MOV R2, A		;R2循环左移(即下一轮中X该让哪一行亮)
	
	DJNZ R7, SSS1		;自减后不为0跳转(SSS1循环，该循环目的是让L1和L2完全亮起来)
	
	MOV R7, #8
	MOV R2, #1		;数据重置
SSS2:				;因后先输入R2后0的原因，实际上是点亮L3和L4
	MOV R0, #0
	MOV A, R2
	MOV R1, A
	
	ACALL XSHIFTOUT		;X输出(控制哪一行可以亮，L1L2或L3L4)
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R1, A		;R1存入L3显示数据
	
	INC PTR			;偏移自加
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R0, A		;R0存入L4显示数据

	ACALL YSHIFTOUT		;Y输出(控制X指定的那一行怎么亮)
	
	ACALL DELAY		;延迟
	
	INC PTR			;偏移自加
	
	MOV A, R2
	RL A
	MOV R2, A		;R2循环左移(即下一轮中X该让哪一行亮)
	
	DJNZ R7, SSS2		;自减后不为0跳转(SSS1循环，该循环目的是让L3和L4完全亮起来)
	
	DJNZ R3, RST	
	MOV R3, #5		;循环停顿，刷新R3次
	
	INC BPTR
	INC BPTR		;使下次显示整体左移
	CJNE BPTR, #128, RST	;不相等转移，一个字是32字节，128表示四个字完全显示完毕（要根据字的个数更改）
	MOV BPTR, #0
RST:				;控制移动快慢
	MOV A, BPTR
	MOV PTR, A		;现场回退
	AJMP LP



XSHIFTOUT:
	MOV ACC, R7
	PUSH ACC		;现场保存，外部大循环
	
	CLR CKXL		;RCK存储器清0
	SETB ENX		;使能端置1
	
	MOV R7, #8
	MOV A, R1
XSH1:	
	RLC A			;左移一位
	;SHIFT REGISTER
	MOV DX, C		;BIT DATA
	CLR CKX			;SRCK移位寄存器清0
	SETB CKX		;SRCK置1即上升沿，数据移动到位移寄存器中
	DJNZ R7, XSH1		;自减不为0跳转，循环八次，数据全部转移到位移寄存器中
	
	MOV R7, #8
	MOV A, R0
XSH0:
	RLC A
	;SHIFT REGISTER
	MOV DX, C		;输入一位数据
	CLR CKX
	SETB CKX		;CLOCK
	DJNZ R7, XSH0
	
	SETB CKXL		;RCK置1，数据转移到存储寄存器中(锁存)
	CLR ENX			;使能端清0
	
	POP ACC
	MOV R7, ACC		;现场恢复
	RET
	
YSHIFTOUT:			;所有功能同XSHIFTOUT，仅改变接口
	MOV ACC, R7
	PUSH ACC
	
	CLR CKYL
	SETB ENY
	
	MOV R7, #8
	MOV A, R1
YSH1:
	RLC A
	;SHIFT REGISTER
	MOV DY, C
	CLR CKY
	SETB CKY
	DJNZ R7, YSH1
	
	MOV R7, #8
	MOV A, R0
YSH0:
	RLC A
	;SHIFT REGISTER
	MOV DY, C
	CLR CKY
	SETB CKY
	DJNZ R7, YSH0
	
	SETB CKYL
	CLR ENY
	
	POP ACC
	MOV R7, ACC
	RET



DELAY:				;延时程序
	MOV ACC, R7
	PUSH ACC
	MOV ACC, R6
	PUSH ACC
	MOV R6, #20
	MOV R7, #255
DL:
	DJNZ R7, DL
	DJNZ R6, DL
	POP ACC
	MOV R6, ACC
	POP ACC
	MOV R7, ACC
	RET

END
