ORG 0000H 		;复位起始地址
	LJMP START
ORG 000BH 		;中间地址保留给中断向量表 定时器的中断部分，更改R7
	LJMP INTERRUPT_T0 ;定时器0中断程序入口地址
ORG 0040H 		;程序实际起始地址

START: 			;初始化
	P4 EQU 0C0H 	;单片机P4口地址，PPT中给出
	P4SW EQU 0BBH 	;P4 方式控制字地址
	MOV P4SW,#70H 	;将P4口设置为普通的IO口，则P4SW=0X70
	CLK EQU P4.4 	;时钟线
	DAT EQU P4.5 	;数据线
	SW EQU P3.6 	;该单片机上电复位后须设置P4SW寄存器
	MOV DPTR,#DIGIT_TABLE ;将断码表首地址传给数据指针寄存器

INIT:
	MOV R3,#0 	;计数 数码管显示 个位
	MOV R4,#0 	;计数 数码管显示 十位
	MOV R5,#0 	;计数 数码管显示 百位

SETTING:		;TMOD 方式寄存器(设置方式参考C51手册)
	MOV TMOD,#01H 	; TMOD是方式寄存器0000 0001B 定时方式，不受外部控制
	MOV IE,#82H 	;允许中断,T0中断允许 中断控制字 直接对中断寄存器IE 和优先级寄存器 IP设置
	ORL IP,#2H 	;逻辑或,T0中断的优先级高
	SETB P1.1 	;CE1 置1
	SETB P1.4 	;CE2 置1

GET_TIME_ORDER:
	JB P3.7,REVERSE 	;若P3.7=1,s2松开跳转到OPP
	MOV R0, #01111000B 	;按下s2为顺时针 R0=78 01-->11-->10-->00
	MOV 20H,R0 		;将步进电机的脉冲时序排序存储到20H地址中
	LJMP JUDGE_SPEED

REVERSE:
	MOV R0, #00101101B 	;松开为逆时针 RO=2D 00-->10-->11-->01
	MOV 20H,R0 		;将步进电机的脉冲时序排序存储到20H地址中

JUDGE_SPEED:
	JB P3.6,SLOW_SPEED 	;P3.6=1,s1松开---->慢速 跳转；
				;P3.6=0，s1按下---->快速
	MOV R2,#0H 		;快速(5D3E #DIGIT_TABLE)
	LJMP STEP_BY_ORDER

SLOW_SPEED:
	MOV R2,#1H 	;慢速

STEP_BY_ORDER:
	MOV R1,#4 	;相位四次变换，将对应的循环次数4保存到R1中
	MOV R0,20H 	;取出步进电机的脉冲时序

STEPPING:
	MOV A,R0 	; A=R0 存放脉冲时序
	RLC A 		; 累加器A 循环左移
	MOV P3.2,C 	;IN1 脉冲高一位送至INT1
	RLC A 		; 再次左移一位
	MOV P1.0,C 	; IN2 低一位送至INT2
	MOV R0,A 	; 将累加器A循环左移两位之后的结果保存到R0中(即新的时序)
	LCALL SHOW_DIGITS 	;LED显示器显示步进电机的已转动的次数
	LCALL CLOCKING 		;定时器
	DJNZ R1,STEPPING 	;R1=R1-1，结果不为0继续循环，循环次数4(R1=4)
	LJMP GET_TIME_ORDER 

CLOCKING:
	CJNE R2,#1,FAST_COUTING ;跳转说明R2=0H 快速
	MOV R6,#6 		;慢速六次计时

INIT_COUNT:
	MOV TH0,#5DH 	;初值5D3E
	MOV TL0,#3EH
	SETB TR0 	;计时器0启动，如果CPU响应定时器中断则此位为1时
			;发生定时器中断，在中断响应时由硬件清零。
	MOV R7,#0H 	;R7为中断判断标志，置0

SLOW_COUNTING:
	CJNE R7,#1H,SLOW_COUNTING	;如果中断，R7=1H
	DJNZ R6,INIT_COUNT 		;R6-1，结果不为0继续循环
	LJMP OUT

FAST_COUTING:
	MOV TH0,#5DH 
	MOV TL0,#3EH
	SETB TR0 
	MOV R7,#0H 

DO_FAST:
	CJNE R7,#1H,DO_FAST 	;若等于0则顺次执行即直接跳出

OUT:
RET


INTERRUPT_T0: 		;中断程序
	MOV R7,#1 	;中断标志置1
RETI

SHOW_DIGITS: ;调用LED显示器的子程序，显示步进电机已转动的次数

DISPLAY:
	MOV A,R3
	CALL TO_TUBE ;显示个位
	MOV A,R4
	CALL TO_TUBE ;显示十位
	MOV A,R5
	CALL TO_TUBE ;显示百位
	;+1,if(999)->0
	CJNE R3,#9,S1 ;个位
	MOV R3,#0 
	CJNE R4,#9,S2 ;十位
	MOV R4,#0
	CJNE R5,#9,S3 ;百位
	MOV R5,#0

S1:
	INC R3
	LJMP DONE

S2:
	INC R4
	LJMP DONE

S3:
	INC R5
	LJMP DONE

DONE:
RET

TO_TUBE: 		;显示数码管 R0 存在21H处
	MOV 21H,R0 	;压栈，保存之前R0的值
			;A=R3 即位数字，段码表中按数字递增存放
			;故 @A+DPTR 就是R3中对应数字的段码
	MOVC A,@A+DPTR 	;将累加器与数据指针寄存器的值相加存到A中
	MOV R0,#8 

TRIGGER:
	CLR CLK 	;P4.4 通过CLR清0 低电平
	RLC A 		;累加器A左移一位，最高位移到C中
	MOV DAT,C 	;8位数据按位输出
	SETB CLK 	;P4.4 时钟线高电平，产生上升沿
	DJNZ R0,TRIGGER ;不为0 跳转
	MOV R0,21H 	;弹栈，恢复R0
	RET 		;返回主程序

DIGIT_TABLE:
	DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H
END