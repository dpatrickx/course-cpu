### CMP
+ IF/ID
	1. 10-8 rs 7-5 rt
+ ID
	1. 读出rs和rt的值A B
+ ID/EX
	1. 存A B
+ EX
	1. 传入A和B
	2. 比较，返回0/1
+ EX/MEM
	1. 结果存在ans
+ MEM
	1. nothing
+ MEM/WB
	1. 结果传到data
+ WB
	1. 根据控制信号将data写入T寄存器
+ 控制信号如何传送？

--------
### MFPC
+ IF/ID
	1. 10-8 rd PC
+ ID
	1. nothing
+ ID/EX
	1. 存rd
	2. PC值
+ EX
	1. 传入PC
	2. 控制信号控制ALU直接返回下端传入值, 并没有用
+ EX/MEM
	1. 存rd
	2. 存PC
+ MEM
	1. nothing
+ MEM/WB
	1. 结果使用PC
+ WB
	1. 根据控制信号将PC写入寄存器rd


--------
### MFIH
+ IF/ID
	1. 10-8 rd
+ ID
	1. 控制信号控制读出IH的值
+ ID/EX
	1. 存rd
	2. IH值
+ EX
	1. 传入IH
	2. 控制信号控制ALU直接返回下端传入值IH
+ EX/MEM
	1. 存rd
	2. 存ans即IH
+ MEM
	1. nothing
+ MEM/WB
	1. 结果使用IH
+ WB
	1. 根据控制信号将data写入寄存器rd

--------
### MFIH
+ IF/ID
	1. 10-8 rd
+ ID
	1. 控制信号控制读出IH的值
+ ID/EX
	1. 存rd
	2. IH值
+ EX
	1. 传入IH
	2. 控制信号控制ALU直接返回下端传入值IH
+ EX/MEM
	1. 存rd
	2. 存ans即IH
+ MEM
	1. nothing
+ MEM/WB
	1. 结果使用IH
+ WB
	1. 根据控制信号将data写入寄存器rd

--------
### MTIH
+ IF/ID
	1. 10-8 rs
+ ID
	1. 读rs的值A
+ ID/EX
	1. 存A
+ EX
	1. 传入A
	2. 控制信号控制ALU直接返回上端传入值IH
+ EX/MEM
	1. 存ans
+ MEM
	1. nothing
+ MEM/WB
	1. 结果使用data
+ WB
	1. 根据控制信号将data写入寄存器IH

--------
### SLL
+ IF/ID
	1. 10-8 rd 7-5 rt
+ ID
	1. 读rt的值B
+ ID/EX
	1. 存B
	2. 存im
	3. 存rd
+ EX
	1. 传入B
	2. 传入im
	2. 输出结果到ans
+ EX/MEM
	1. 存ans
	2. 存rd
+ MEM
	1. nothing
+ MEM/WB
	1. 存data
	2. 存rd
+ WB
	1. 根据控制信号将data写入寄存器IH


--------
### B
+ IF/ID
	1. 存im PC
+ ID
	1. 计算pc值加立即数
	2 . 写pc
+ 控制信号控制什么都不做

	