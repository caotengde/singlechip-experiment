DX EQU P0.0	;��λ�Ĵ��������������Dx
CKX EQU P0.1	;SRCK��λ�Ĵ���x����ʱ������
CKXL EQU P0.2	;RCK�洢��x����ʱ������
ENX EQU P0.7	;�洢��x����ʹ�ܶ˿�

DY EQU P0.3	;��λ�Ĵ��������������Dy
CKY EQU P0.5	;SRCK��λ�Ĵ���y����ʱ������
CKYL EQU P0.6	;RCK�洢��y����ʱ������
ENY EQU P0.4	;�洢��y����ʹ�ܶ˿�

PTR EQU R5
BPTR EQU R4	;ƫ��

ORG 0000H
	LJMP START
ORG 0040H

LEDTABLE:
DB 0FFH ,0FFH ,0FFH ,0EFH ,0FFH ,06FH ,0FFH ,06FH ,0FFH ,05BH ,0F9H ,043H ,0F6H ,0BFH ,0BEH ,0F7H;
DB 080H ,0F7H ,0FDH ,02FH ,0FDH ,0CFH ,0EFH ,037H ,0FFH ,07BH ,0FFH ,0F9H ,0FFH ,0F1H ,0FFH ,0FFH;"��",0
DB 0FFH ,0FFH ,0FFH ,0FFH ,0FBH ,0BFH ,0FAH ,067H ,0F9H ,0FFH ,080H ,037H ,0F6H ,0FBH ,0FBH ,0FBH;
DB 0E0H ,00DH ,0EAH ,0BDH ,0EFH ,0BDH ,0EFH ,0B3H ,0E0H ,07BH ,0FFH ,0EFH ,0FFH ,0EFH ,0FFH ,0FFH;"��",1
DB 0FFH ,0FFH ,0F8H ,0FFH ,0FBH ,07FH ,0FBH ,07FH ,0F0H ,07FH ,0FBH ,0FFH ,0FFH ,0FFH ,0F9H ,067H;
DB 0F7H ,01BH ,08AH ,07BH ,0FAH ,0FDH ,0F7H ,0FDH ,0F7H ,0F9H ,0FFH ,0FBH ,0FFH ,0E3H ,0FFH ,0FFH;"��",2
DB 0FFH ,0FFH ,0FFH ,07FH ,0FCH ,0FFH ,0F2H ,083H ,0CAH ,06FH ,0FBH ,0EBH ,0FBH ,0F7H ,0F3H ,08FH;
DB 0F0H ,07FH ,0F6H ,037H ,0EEH ,0CFH ,0CDH ,00FH ,0FEH ,0F7H ,0FFH ,0F3H ,0FFH ,0FBH ,0FFH ,0FBH;"��",3
DB 0FFH ,0FFH ,0FFH ,0EFH ,0FFH ,06FH ,0FFH ,06FH ,0FFH ,05BH ,0F9H ,043H ,0F6H ,0BFH ,0BEH ,0F7H;
DB 080H ,0F7H ,0FDH ,02FH ,0FDH ,0CFH ,0EFH ,037H ,0FFH ,07BH ,0FFH ,0F9H ,0FFH ,0F1H ,0FFH ,0FFH;"��",0
;��һ������Ҫ�ظ����������Ϊ�ַ���ƫ�Ƶ�ĩβʱ�������������ʾ����ȷ


;led��ʾ������
;    U4  U3  (Y)
;U2  L3  L4
;U1  L1  L2
;(X)

START:
	MOV DPTR, #LEDTABLE
	MOV BPTR, #0		;��������ƫ��
	MOV PTR, #0		;16x16�ַ���ƫ��
	MOV R3, #5		;R3Ϊ����ÿ������������Ļ��ͣ�ٵ�֡�������ظ�����ǰ��Ļ�ظ����R3�Σ�
	
LP:
	MOV R7, #8		;ѭ������
	MOV R2, #1		;x������һ�п�������ÿ��ֻ�ܵ���һ�У�
SSS1:				;���������0��R2��ԭ��ʵ�����ǵ���L1��L2
	MOV A, R2
	MOV R0, A		
	MOV R1, #0
	
	ACALL XSHIFTOUT		;X���(������һ�п�������L1L2��L3L4)
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R1, A		;R1����L1��ʾ����
	
	INC PTR			;ƫ���Լ�
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R0, A		;R0����L2��ʾ����

	ACALL YSHIFTOUT		;Y���(����Xָ������һ����ô��)
	
	ACALL DELAY		;�ӳ�
	
	INC PTR			;ƫ���Լ�
	
	MOV A, R2
	RL A
	MOV R2, A		;R2ѭ������(����һ����X������һ����)
	
	DJNZ R7, SSS1		;�Լ���Ϊ0��ת(SSS1ѭ������ѭ��Ŀ������L1��L2��ȫ������)
	
	MOV R7, #8
	MOV R2, #1		;��������
SSS2:				;���������R2��0��ԭ��ʵ�����ǵ���L3��L4
	MOV R0, #0
	MOV A, R2
	MOV R1, A
	
	ACALL XSHIFTOUT		;X���(������һ�п�������L1L2��L3L4)
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R1, A		;R1����L3��ʾ����
	
	INC PTR			;ƫ���Լ�
	
	MOV A, PTR
	MOVC A, @A+DPTR
	MOV R0, A		;R0����L4��ʾ����

	ACALL YSHIFTOUT		;Y���(����Xָ������һ����ô��)
	
	ACALL DELAY		;�ӳ�
	
	INC PTR			;ƫ���Լ�
	
	MOV A, R2
	RL A
	MOV R2, A		;R2ѭ������(����һ����X������һ����)
	
	DJNZ R7, SSS2		;�Լ���Ϊ0��ת(SSS1ѭ������ѭ��Ŀ������L3��L4��ȫ������)
	
	DJNZ R3, RST	
	MOV R3, #5		;ѭ��ͣ�٣�ˢ��R3��
	
	INC BPTR
	INC BPTR		;ʹ�´���ʾ��������
	CJNE BPTR, #128, RST	;�����ת�ƣ�һ������32�ֽڣ�128��ʾ�ĸ�����ȫ��ʾ��ϣ�Ҫ�����ֵĸ������ģ�
	MOV BPTR, #0
RST:				;�����ƶ�����
	MOV A, BPTR
	MOV PTR, A		;�ֳ�����
	AJMP LP



XSHIFTOUT:
	MOV ACC, R7
	PUSH ACC		;�ֳ����棬�ⲿ��ѭ��
	
	CLR CKXL		;RCK�洢����0
	SETB ENX		;ʹ�ܶ���1
	
	MOV R7, #8
	MOV A, R1
XSH1:	
	RLC A			;����һλ
	;SHIFT REGISTER
	MOV DX, C		;BIT DATA
	CLR CKX			;SRCK��λ�Ĵ�����0
	SETB CKX		;SRCK��1�������أ������ƶ���λ�ƼĴ�����
	DJNZ R7, XSH1		;�Լ���Ϊ0��ת��ѭ���˴Σ�����ȫ��ת�Ƶ�λ�ƼĴ�����
	
	MOV R7, #8
	MOV A, R0
XSH0:
	RLC A
	;SHIFT REGISTER
	MOV DX, C		;����һλ����
	CLR CKX
	SETB CKX		;CLOCK
	DJNZ R7, XSH0
	
	SETB CKXL		;RCK��1������ת�Ƶ��洢�Ĵ�����(����)
	CLR ENX			;ʹ�ܶ���0
	
	POP ACC
	MOV R7, ACC		;�ֳ��ָ�
	RET
	
YSHIFTOUT:			;���й���ͬXSHIFTOUT�����ı�ӿ�
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



DELAY:				;��ʱ����
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
