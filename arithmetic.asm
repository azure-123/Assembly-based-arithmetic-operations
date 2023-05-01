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
	INT	21H	;输出提示信息
	LEA	DX,BUFFER
	MOV	AH,0AH
	INT	21H	;输入表达式
	CRLF
	
	MOV	CL,BUFFER+1
	MOV	CH,0
	MOV	COUNT,CL	
	LEA	SI,BUFFER+2
	LEA	BX,COPY
TRANS:	MOV	AH,0
	MOV	AL,[SI]	;将元素放进AL中
	CMP	AL,'0'	;判断是否为数字
	JB	NEXT0	;若ASCII小于'0',说明不是数字,不做额外处理
NUM:	CMP	AL,'9'	
	JA	NEXT0	;同理,若ASCII大于'9',说明不是数字,不做额外处理
	SUB	AL,30H	;筛选下来的数字进行转换
NEXT0:	MOV	[BX],AX	;将该字符复制到拷贝数组
	INC	SI
	ADD	BX,2
	LOOP	TRANS
;此部分进行字符串的预处理,将所有表示数字的字符都转化为数字本身

	LEA	SI,COPY+4	;直接从数字开始
	MOV	CL,COUNT	;数字和运算符个数
	SUB	CL,2
	MOV	DX,100		;准备乘100
COMP0:	MOV	AX,[SI]	;元素放入AX
	MOV	BX,[SI-2]
	CMP	AX,0	
	JB	JUMP
	CMP	AX,9
	JA	JUMP	;判断AX中是否为数字
	CMP	BX,'*'	;若作为乘数无需多次乘100
	JE	JUMP
	CMP	BX,'/'	;若作为除数无需乘100
	JE	JUMP
	MUL	DL
	MOV	[SI],AX
JUMP:	ADD	SI,2
	LOOP	COMP0

	LEA	SI,COPY
	MOV	CL,COUNT
COMP1:	MOV	AX,[SI]	;将元素放进AX中
	CMP	AX,'*'	;判断符号是否为乘号
	JNZ	DIVI	;不是乘号，跳转，判断是否为除号
	MOV	BX,[SI-2]	;将乘号前的数字放进BX中
	MOV	AX,[SI+2]	;将乘号后的数字放进AX中
	MOV	DX,0
	MUL	BX	;两数相乘放入DX:AX
	MOV	[SI+2],AX	;AX中数值放入下一元素
	MOV	WORD PTR[SI-2],0	;第一个数的位置置零
	MOV	WORD PTR[SI],0	;乘号位置置零
DIVI:	CMP	AX,'/'	;与除号相比较
	JNZ	NEXT	;不是除号，直接进入下一个循环	
	PUSH	BX
	PUSH	CX
	PUSH	DX	;保护数据
	MOV	AX,[SI-2]	;将被除数放进AL中
	MOV	BX,[SI+2]	;将除数放进BL中
	MOV	DX,0
	DIV	BX	;除法运算
	MOV	[SI+2],AX	;并将结果放入除数位置
	MOV	WORD PTR[SI],0	;将字符串的除号部分置零
	MOV	WORD PTR[SI-2],0	;将字符串的被除数部分置零
	POP	DX
	POP	CX
	POP	BX	;恢复数据	
NEXT:	ADD	SI,2	;指针指向下一个元素
	LOOP	COMP1	;循环
;此部分的作用就是进行乘除优先计算


	LEA	SI,COPY+4
	MOV	CL,COUNT
	SUB	CL,2
	MOV	BX,0	;先将BX寄存器初始化为0状态,这样第一个数字可以自动默认为加
ADDMIN:	MOV	AX,[SI]	;第一个元素放入AX
	CMP	AX,'+'	;判断是否为加号
	JE	PLUS
	CMP	AX,'-'	;判断是否为减号
	JE	MINUS
COMP2:	CMP	BX,0	;判断BX寄存器中的值
	JE	NPLUS	;作加法运算
	CMP	BX,1	
	JE	NMINUS	;作减法运算
NPLUS:	ADD	SUM,AX	;加
	JMP	LOP
NMINUS:	SUB	SUM,AX	;减去整数部分
	JMP	LOP
PLUS:	MOV	BX,0	;如果出现的是加号就将BX置为0
	JMP	LOP
MINUS:	MOV	BX,1	;如果出现的是减号就将BX置为1
	JMP	LOP	
LOP:	ADD	SI,2	;指针指向下一个元素
	LOOP	ADDMIN

	MOV	AX,SUM
	MOV	DX,0
	MOV	BX,1000
	DIV	BX	;取第一位数
	MOV	NUMS,AL
	MOV	AX,DX
	MOV	DX,0
	MOV	BX,100
	DIV	BX	;取第二位数
	MOV	NUMS+1,AL
	MOV	AX,DX
	MOV	DX,0
	MOV	BX,10
	DIV	BX	;取第三位数
	MOV	NUMS+2,AL
	MOV	NUMS+3,DL;第四位数

	MOV	DL,BUFFER+2
	MOV	AH,2
	INT	21H	;输出字母
	MOV	DL,'='
	MOV	AH,2
	INT	21H	;输出等号
	MOV	DL,NUMS
	CMP	DL,0
	JE	OUTPUT	;判断第一位是否为0，若为0，不显示
	ADD	DL,30H
	MOV	AH,2
	INT	21H	;第一位不是0，显示
OUTPUT:	MOV	DL,NUMS+1
	ADD	DL,30H
	MOV	AH,2
	INT	21H	;输出第二位数
	MOV	DL,'.'
	MOV	AH,2
	INT	21H	;输出小数点
	MOV	DL,NUMS+2
	MOV	AL,NUMS+3
	CMP	AL,5	;判断第四位数的值是否大于5，进行四舍五入操作
	JL	PLUS1
	ADD	DL,1
PLUS1:	ADD	DL,30H
	MOV	AH,2
	INT	21H	;输出第三位数

	MOV	AH,4CH
	INT	21H


CODE	ENDS
	END	START

