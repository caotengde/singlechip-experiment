ORG 0000H 		;��λ��ʼ��ַ
	LJMP START
ORG 000BH 		;�м��ַ�������ж������� ��ʱ�����жϲ��֣�����R7
	LJMP INTERRUPT_T0 ;��ʱ��0�жϳ�����ڵ�ַ
ORG 0040H 		;����ʵ����ʼ��ַ

START: 			;��ʼ��
	P4 EQU 0C0H 	;��Ƭ��P4�ڵ�ַ��PPT�и���
	P4SW EQU 0BBH 	;P4 ��ʽ�����ֵ�ַ
	MOV P4SW,#70H 	;��P4������Ϊ��ͨ��IO�ڣ���P4SW=0X70
	CLK EQU P4.4 	;ʱ����
	DAT EQU P4.5 	;������
	SW EQU P3.6 	;�õ�Ƭ���ϵ縴λ��������P4SW�Ĵ���
	MOV DPTR,#DIGIT_TABLE ;��������׵�ַ��������ָ��Ĵ���

INIT:
	MOV R3,#0 	;���� �������ʾ ��λ
	MOV R4,#0 	;���� �������ʾ ʮλ
	MOV R5,#0 	;���� �������ʾ ��λ

SETTING:		;TMOD ��ʽ�Ĵ���(���÷�ʽ�ο�C51�ֲ�)
	MOV TMOD,#01H 	; TMOD�Ƿ�ʽ�Ĵ���0000 0001B ��ʱ��ʽ�������ⲿ����
	MOV IE,#82H 	;�����ж�,T0�ж����� �жϿ����� ֱ�Ӷ��жϼĴ���IE �����ȼ��Ĵ��� IP����
	ORL IP,#2H 	;�߼���,T0�жϵ����ȼ���
	SETB P1.1 	;CE1 ��1
	SETB P1.4 	;CE2 ��1

GET_TIME_ORDER:
	JB P3.7,REVERSE 	;��P3.7=1,s2�ɿ���ת��OPP
	MOV R0, #01111000B 	;����s2Ϊ˳ʱ�� R0=78 01-->11-->10-->00
	MOV 20H,R0 		;���������������ʱ������洢��20H��ַ��
	LJMP JUDGE_SPEED

REVERSE:
	MOV R0, #00101101B 	;�ɿ�Ϊ��ʱ�� RO=2D 00-->10-->11-->01
	MOV 20H,R0 		;���������������ʱ������洢��20H��ַ��

JUDGE_SPEED:
	JB P3.6,SLOW_SPEED 	;P3.6=1,s1�ɿ�---->���� ��ת��
				;P3.6=0��s1����---->����
	MOV R2,#0H 		;����(5D3E #DIGIT_TABLE)
	LJMP STEP_BY_ORDER

SLOW_SPEED:
	MOV R2,#1H 	;����

STEP_BY_ORDER:
	MOV R1,#4 	;��λ�Ĵα任������Ӧ��ѭ������4���浽R1��
	MOV R0,20H 	;ȡ���������������ʱ��

STEPPING:
	MOV A,R0 	; A=R0 �������ʱ��
	RLC A 		; �ۼ���A ѭ������
	MOV P3.2,C 	;IN1 �����һλ����INT1
	RLC A 		; �ٴ�����һλ
	MOV P1.0,C 	; IN2 ��һλ����INT2
	MOV R0,A 	; ���ۼ���Aѭ��������λ֮��Ľ�����浽R0��(���µ�ʱ��)
	LCALL SHOW_DIGITS 	;LED��ʾ����ʾ�����������ת���Ĵ���
	LCALL CLOCKING 		;��ʱ��
	DJNZ R1,STEPPING 	;R1=R1-1�������Ϊ0����ѭ����ѭ������4(R1=4)
	LJMP GET_TIME_ORDER 

CLOCKING:
	CJNE R2,#1,FAST_COUTING ;��ת˵��R2=0H ����
	MOV R6,#6 		;�������μ�ʱ

INIT_COUNT:
	MOV TH0,#5DH 	;��ֵ5D3E
	MOV TL0,#3EH
	SETB TR0 	;��ʱ��0���������CPU��Ӧ��ʱ���ж����λΪ1ʱ
			;������ʱ���жϣ����ж���Ӧʱ��Ӳ�����㡣
	MOV R7,#0H 	;R7Ϊ�ж��жϱ�־����0

SLOW_COUNTING:
	CJNE R7,#1H,SLOW_COUNTING	;����жϣ�R7=1H
	DJNZ R6,INIT_COUNT 		;R6-1�������Ϊ0����ѭ��
	LJMP OUT

FAST_COUTING:
	MOV TH0,#5DH 
	MOV TL0,#3EH
	SETB TR0 
	MOV R7,#0H 

DO_FAST:
	CJNE R7,#1H,DO_FAST 	;������0��˳��ִ�м�ֱ������

OUT:
RET


INTERRUPT_T0: 		;�жϳ���
	MOV R7,#1 	;�жϱ�־��1
RETI

SHOW_DIGITS: ;����LED��ʾ�����ӳ�����ʾ���������ת���Ĵ���

DISPLAY:
	MOV A,R3
	CALL TO_TUBE ;��ʾ��λ
	MOV A,R4
	CALL TO_TUBE ;��ʾʮλ
	MOV A,R5
	CALL TO_TUBE ;��ʾ��λ
	;+1,if(999)->0
	CJNE R3,#9,S1 ;��λ
	MOV R3,#0 
	CJNE R4,#9,S2 ;ʮλ
	MOV R4,#0
	CJNE R5,#9,S3 ;��λ
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

TO_TUBE: 		;��ʾ����� R0 ����21H��
	MOV 21H,R0 	;ѹջ������֮ǰR0��ֵ
			;A=R3 ��λ���֣�������а����ֵ������
			;�� @A+DPTR ����R3�ж�Ӧ���ֵĶ���
	MOVC A,@A+DPTR 	;���ۼ���������ָ��Ĵ�����ֵ��Ӵ浽A��
	MOV R0,#8 

TRIGGER:
	CLR CLK 	;P4.4 ͨ��CLR��0 �͵�ƽ
	RLC A 		;�ۼ���A����һλ�����λ�Ƶ�C��
	MOV DAT,C 	;8λ���ݰ�λ���
	SETB CLK 	;P4.4 ʱ���߸ߵ�ƽ������������
	DJNZ R0,TRIGGER ;��Ϊ0 ��ת
	MOV R0,21H 	;��ջ���ָ�R0
	RET 		;����������

DIGIT_TABLE:
	DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H
END