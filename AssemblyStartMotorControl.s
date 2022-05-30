__main PROC
	;HIS CODE altered 18-42
	;Partner: Dan young
	;This is a spin off project for an example PWM(Mock)motor control sequence controlled by buttons onboard the STM32L4 board

	   BL RCC_Init
	   BL GPIO_Init
	   LDR R0,=GPIOE_BASE
	   ADR R1, seq3
	   MOV R5, R1
	   LDR R12,=GPIOA_BASE
	   LDR R6, =3000
	   LDR R10, =0
	   LDR R11, =200
	
loop   ;incRiment steppeR motoR and update ODR

;R0: GPIO_BASE AND SEQUENCE_N (Vital)
;R1: ARRay of sequences (Constant)
;R2: ARRay iteRatoR (TempoRaRy)
;R3: GPIO_ODR holdeR (TempoRaRy)
;R4: Bit CleaR holdeR (TempoRaRy)
;R5: GPIOE_BASE (Constant)
;R6: SPEED ARRAY (Vital) 
;R7: GPIO_IDR (Temporary)
;R8: CC_CCW State (Vital)
;R9: Tempfor reverse direction testing branch, assigns whatever other array we are testing for
;R10:Temp for my motor now for 200 steps
;R11:
;R12: GPIOA_BASE (Constant)

		;Check foR up button [SPEED_UP]
		LDR R7, [R12, #GPIO_IDR]
		LDR R11, =0x00000008; Checking foR PA3 TOP BUTTON
		AND R7, R11 ; RetuRn and check value against input
		CMP R7, R11 ; CompaRe PA1 and the value the input should be 0x0...2
		BEQ AddSpeed
		


		;Check foR down button [SPEED_DOWN]
		LDR R7, [R12,#GPIO_IDR]
		LDR R11, =0x00000020 ; Masking foR PA5(IDR6) DOWN BUTTON
		AND R7, R11 ;Getting only fiRst bit of data fRom PA0
		CMP R7, R11 ;
		BEQ SubSpeed
        


		;Check for center button pressed [Toggle CC/CCW]
		LDR R7, [R12, #GPIO_IDR] 
		LDR R11, =0x00000001 ;Checking foR PA0 BUTTON
		;LDR R8, =0x0001
		AND R7, R11 ; RetuRn and check value against input
		;EOR R8, #0x0001
		CMP R7, R11
		BEQ RevTest ; go to the testing area that finds out which reverse to go in
		

		

		;CMP R7, R11 ; CompaRe PA2 and the value the input should be 0x0...4
		;BEQ counteRclockwiseFull ; BRanch to counteR clockwise fullstep aRRay if Right input
		
		;Checking foR Left button [CW_HALF]
		LDR R7, [R12, #GPIO_IDR]
		LDR R11, =0x00000002 ; Checking foR PA1 LEFT BUTTON
		AND R7, R11; RetuRn and check value against input 
		
		CMP R7, R11 ; CompaRe PA3 and the value the input should be 0x0...2
		BEQ clockwiseHalf ; BRanch to clockwise halfstep aRRay if up input
		
		;Checking FOR Right button [CW_FULL]
		LDR R7,[R12, #GPIO_IDR]
		LDR R11, =0x00000004 ; Checking foR PA2 RIGHT BUTTON
		AND R7, R11 ; RetuRn and check value against input
		
		CMP R7, R11 ; CompaRe PA2 and the value the input should be 0x0...04
		BEQ clockwiseFull
		
		;ADR R1, seq5 ; Setting counteRclockwise halfstep
		B  continue ; incRiment and update ODR
		

;BRanch foR assigning sequence 2 [seq2]; CCW_FULL
;counteRclockwiseFull
;		ADR R1, seq2 ; Setting two phase counteRclockwise fullstep
;		B  continue
		
;BRanch foR assigning sequence 6 [seq6]; CW_HALF
clockwiseHalf
		ADR R1, seq5 ; Setting clockwise halfstep
		MOV R5, R1
		B  continue



	   ENDP 

USART_Init PROC
		   PUSH{R0,R1,R2, R3, R4}
		   ;NEED TO FIND BASE REGISTER MAYBE?
		   LDR R3, =0xFFFFFFFF ; Used for XOR to rev bits
		   LDR R4, =218 ; Used for congfiguration of baud rate
		   
		   LDR R0, =USART1_BASE
		   LDR R1, [R0,#USART_CR1] ; Control register 1
		   EOR R2, R3, USART_CR1_M ; reverse bits
		   BIC R1, R1, R2 ; Clearing the reverse of USART_CR1_M
		   ORR R2, USART_CR1_RE, USART_CR1_TE ; Transmit and Recieve Enable
		   STR R1, [R0, #USART_CR1] ; Set register to 8bit length
		   
		   
		   LDR R1, [R0, #USART_CR2] ; Control register 2
		   EOR R2, R3, USART_CR2_STOP ; reverse bits
		   BIC R1, R1, R2 ; Clearing the reverse of USART_CR2_M
		   ORR R2, USART_CR1_UE, #0 ; Being kinda lazy here, but I can call ORR with same constants twice?
		   
		   STR R1, [R0, #USART_CR2] ; Set register to 1 stop bit
		   
		   LDR R1, [R0, #USART_BRR] ; Control baud rate register
		   ORR R1, R1, R4 ; Set baud rate
		   STR R1, [R0, #USART_BRR] ; Set register to 218 baud rate
		   
		   
		   
		   POP{R4, R3,R2,R1, R0}
	
		   ENDP

GPIO_Init PROC
		  PUSH {R0,R1,R2}
	;Now initializing GPIOB PB2,3,6,7 THIS WILL be COLUMNS OUTPUT
		  LDR R0, =GPIOB_BASE
		  LDR R1, [R0,#GPIO_MODER]
		  LDR R2, =0x0000F0F0 ; Setting to Output mode
		  BIC R1,R1,R2
		  LDR R2, =0x00005050 ; Output 
		  ORR R1, R1, R2
		  STR R1, [R0, #GPIO_MODER]
		  
		  LDR R1, [R0, #GPIO_OSPEEDR]
		  LDR R2, =0x0000F0F0
		  ORR R1, R1, R2
		  STR R1, [r0,#GPIO_OSPEEDR]
		  
		  LDR R1, [R0, #GPIO_PUPDR]
		  LDR R2, =0x0000F0F0
		  BIC R1, R1, R2
		  LDR R2, =0x00000000
		  ORR R1, R1, R2
		  STR R1, [R0, #GPIO_PUPDR]
	
	;Now initializing GPIOA PA0,1,2,3, 9-PA10 THIS WILL BE ROWS INPUT					
	      LDR R0, =GPIOA_BASE
	      LDR R1, [R0,#GPIO_MODER]
	      LDR R2, =0x003C00FF ; SET AS INPUT FOR KEYPAD PA0-3
	      BIC  R1,R1,R2 ; Masking essentially I think
	      LDR R2, =0x00280000 ; AltFunc mode and 
	      ORR R1, R1, R2
	      STR R1, [R0,#GPIO_MODER]
	
	      LDR R1, [R0,#GPIO_OSPEEDR]
	      LDR R2, =0x003C0000 ; 40MHZ set for OSPEEDR
	      ORR R1, R1, R2
	      STR R1, [R0,#GPIO_OSPEEDR]
	
	      LDR R1, [R0,#GPIO_PUPDR]
	      LDR R2, =0x003C00FF ; 
	      BIC  R1,R1,R2
	      LDR R2, =0x00000000 ; PUPDR as Npullup/Npulldown
	      ORR R1, R1, R2
	      STR R1, [R0,#GPIO_PUPDR]
	
		  LDR R1, [R0, #GPIO_AFR1] ; Alt Func registers
		  LDR R2, =0x77
		  ORR R1, R1, R2, LSL#4 ; 011101110000? IDK what relevance this is right now
		  STR R1, [R0, #GPIO_AFR1]
		  
		  LDR R2, 
	      LDR R1, [R0,#GPIO_OTYPER]
	      LDR R2, =0x0300
	      BIC  R1, R1, R2
		  LDR R2, =0x0200 ; PA9 as push-pull output, PA10 as floating input
		  ORR R1, R1, R2
	      STR  R1, [R0,#GPIO_OTYPER]
	
	
	      POP  {R2,R1,R0}
	      BX	LR
	      ENDP
 
		
RCC_Init PROC
		 PUSH {R0,R1}
	
		 LDR R0, =RCC_BASE
	     LDR R1, [R0,#RCC_AHB2ENR]
	;AlteRing to include GPIOA foR buttons, just added ORR with GPIOA
	     ORR R1,R1,#RCC_AHB2ENR_GPIOEEN
	     ORR R1,R1,#RCC_AHB2ENR_GPIOAEN
		 ORR R1,R1,#RCC_AHB2ENR_GPIOBEN
	
	     STR R1, [R0,#RCC_AHB2ENR]
	     POP {R1,R0}
	     BX	  LR
	     ENDP
	
Delay  PROC 
	   push {R1}
	   LDR R1, =0xFFFFFFFF
	   AND R1, R1, R6	;initial value foR loop counteR
again  NOP  ;execute two no-opeRation instRuctions
	   
	   subs R1, #1
	   bne again
	   pop {R1}
	   BX LR
	   ENDP	

;segt DCB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71


	END