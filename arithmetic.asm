CRLF	MACRO
	MOV	AH,2
	MOV	DL,0DH
	INT 	21H
	MOV	DL,0AH
	INT 	21H
ENDM

DATA	SEGMENT
BUFFER	DB	18,?,18 DUP(?)
MSG	DB	0DH,"Please input an expression:",0DH,0AH,"$"
COUNT	DB	?
COPY	DW	20 DUP(?)
NUMS	DB	4 DUP(?)
SUM	DW	0
DATA	ENDS

CODE	SEGMENT
	ASSUME	DS:DATA, CS: CODE
START:	MOV 	AX,DATA
	MOV	DS,AX

	
	MOV	AH,9
	MOV	DX,OFFSET MSG
	INT	21H	;�����ʾ��Ϣ
	LEA	DX,BUFFER
	MOV	AH,0AH
	INT	21H	;������ʽ
	CRLF
	
	MOV	CL,BUFFER+1
	MOV	CH,0
	MOV	COUNT,CL	
	LEA	SI,BUFFER+2
	LEA	BX,COPY
TRANS:	MOV	AH,0
	MOV	AL,[SI]	;��Ԫ�طŽ�AL��
	CMP	AL,'0'	;�ж��Ƿ�Ϊ����
	JB	NEXT0	;��ASCIIС��'0',˵����������,�������⴦��
NUM:	CMP	AL,'9'	
	JA	NEXT0	;ͬ��,��ASCII����'9',˵����������,�������⴦��
	SUB	AL,30H	;ɸѡ���������ֽ���ת��
NEXT0:	MOV	[BX],AX	;�����ַ����Ƶ���������
	INC	SI
	ADD	BX,2
	LOOP	TRANS
;�˲��ֽ����ַ�����Ԥ����,�����б�ʾ���ֵ��ַ���ת��Ϊ���ֱ���

	LEA	SI,COPY+4	;ֱ�Ӵ����ֿ�ʼ
	MOV	CL,COUNT	;���ֺ����������
	SUB	CL,2
	MOV	DX,100		;׼����100
COMP0:	MOV	AX,[SI]	;Ԫ�ط���AX
	MOV	BX,[SI-2]
	CMP	AX,0	
	JB	JUMP
	CMP	AX,9
	JA	JUMP	;�ж�AX���Ƿ�Ϊ����
	CMP	BX,'*'	;����Ϊ���������γ�100
	JE	JUMP
	CMP	BX,'/'	;����Ϊ���������100
	JE	JUMP
	MUL	DL
	MOV	[SI],AX
JUMP:	ADD	SI,2
	LOOP	COMP0

	LEA	SI,COPY
	MOV	CL,COUNT
COMP1:	MOV	AX,[SI]	;��Ԫ�طŽ�AX��
	CMP	AX,'*'	;�жϷ����Ƿ�Ϊ�˺�
	JNZ	DIVI	;���ǳ˺ţ���ת���ж��Ƿ�Ϊ����
	MOV	BX,[SI-2]	;���˺�ǰ�����ַŽ�BX��
	MOV	AX,[SI+2]	;���˺ź�����ַŽ�AX��
	MOV	DX,0
	MUL	BX	;������˷���DX:AX
	MOV	[SI+2],AX	;AX����ֵ������һԪ��
	MOV	WORD PTR[SI-2],0	;��һ������λ������
	MOV	WORD PTR[SI],0	;�˺�λ������
DIVI:	CMP	AX,'/'	;�������Ƚ�
	JNZ	NEXT	;���ǳ��ţ�ֱ�ӽ�����һ��ѭ��	
	PUSH	BX
	PUSH	CX
	PUSH	DX	;��������
	MOV	AX,[SI-2]	;���������Ž�AL��
	MOV	BX,[SI+2]	;�������Ž�BL��
	MOV	DX,0
	DIV	BX	;��������
	MOV	[SI+2],AX	;��������������λ��
	MOV	WORD PTR[SI],0	;���ַ����ĳ��Ų�������
	MOV	WORD PTR[SI-2],0	;���ַ����ı�������������
	POP	DX
	POP	CX
	POP	BX	;�ָ�����	
NEXT:	ADD	SI,2	;ָ��ָ����һ��Ԫ��
	LOOP	COMP1	;ѭ��
;�˲��ֵ����þ��ǽ��г˳����ȼ���


	LEA	SI,COPY+4
	MOV	CL,COUNT
	SUB	CL,2
	MOV	BX,0	;�Ƚ�BX�Ĵ�����ʼ��Ϊ0״̬,������һ�����ֿ����Զ�Ĭ��Ϊ��
ADDMIN:	MOV	AX,[SI]	;��һ��Ԫ�ط���AX
	CMP	AX,'+'	;�ж��Ƿ�Ϊ�Ӻ�
	JE	PLUS
	CMP	AX,'-'	;�ж��Ƿ�Ϊ����
	JE	MINUS
COMP2:	CMP	BX,0	;�ж�BX�Ĵ����е�ֵ
	JE	NPLUS	;���ӷ�����
	CMP	BX,1	
	JE	NMINUS	;����������
NPLUS:	ADD	SUM,AX	;��
	JMP	LOP
NMINUS:	SUB	SUM,AX	;��ȥ��������
	JMP	LOP
PLUS:	MOV	BX,0	;������ֵ��ǼӺžͽ�BX��Ϊ0
	JMP	LOP
MINUS:	MOV	BX,1	;������ֵ��Ǽ��žͽ�BX��Ϊ1
	JMP	LOP	
LOP:	ADD	SI,2	;ָ��ָ����һ��Ԫ��
	LOOP	ADDMIN

	MOV	AX,SUM
	MOV	DX,0
	MOV	BX,1000
	DIV	BX	;ȡ��һλ��
	MOV	NUMS,AL
	MOV	AX,DX
	MOV	DX,0
	MOV	BX,100
	DIV	BX	;ȡ�ڶ�λ��
	MOV	NUMS+1,AL
	MOV	AX,DX
	MOV	DX,0
	MOV	BX,10
	DIV	BX	;ȡ����λ��
	MOV	NUMS+2,AL
	MOV	NUMS+3,DL;����λ��

	MOV	DL,BUFFER+2
	MOV	AH,2
	INT	21H	;�����ĸ
	MOV	DL,'='
	MOV	AH,2
	INT	21H	;����Ⱥ�
	MOV	DL,NUMS
	CMP	DL,0
	JE	OUTPUT	;�жϵ�һλ�Ƿ�Ϊ0����Ϊ0������ʾ
	ADD	DL,30H
	MOV	AH,2
	INT	21H	;��һλ����0����ʾ
OUTPUT:	MOV	DL,NUMS+1
	ADD	DL,30H
	MOV	AH,2
	INT	21H	;����ڶ�λ��
	MOV	DL,'.'
	MOV	AH,2
	INT	21H	;���С����
	MOV	DL,NUMS+2
	MOV	AL,NUMS+3
	CMP	AL,5	;�жϵ���λ����ֵ�Ƿ����5�����������������
	JL	PLUS1
	ADD	DL,1
PLUS1:	ADD	DL,30H
	MOV	AH,2
	INT	21H	;�������λ��

	MOV	AH,4CH
	INT	21H


CODE	ENDS
	END	START

