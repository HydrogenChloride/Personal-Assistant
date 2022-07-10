TITLE   8086 Code Template (for EXE file)

       #MAKE_EXE#

DSEG    SEGMENT 'DATA'
SWITCH DB 10000000b, 01000000b, 00100000b, 00010000b, 00001000b, 00000100b, 00000010b, 00000001b, 11111111b, 11111111b, 11111111b
NUMBERS	DB 00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b, 01101111b
Dots	DB	01111111b, 00100000b, 00010000b, 00100000b, 01111111b  
	    DB	01111110b, 00010001b, 00010001b, 00010001b, 01111110b  
	    DB	00000001b, 00000001b, 01111111b, 00000001b, 00000001b  
	    DB	01111111b, 01001001b, 01001001b, 01001001b, 01000001b 
	    DB	01111111b, 00001001b, 00001001b, 00001001b, 01110110b  
wakeUpMsg db 'WAKE UP                                         ' 
notSickMsg  DB 'You are not sick :)              '
sickMsg  DB 'You are sick!   Contact a doctor'
workoutRoutine db '5 mins - Warm up10-Jumping Jacks10-Push ups     ' 
isSick DB 0
wakingHour db 8
currTime db 0    
drinkInterval db 0
hour db ?     
minute db ? 

DSEG    ENDS

SSEG    SEGMENT STACK   'STACK'
        DW      100h    DUP(?)
SSEG    ENDS

CSEG    SEGMENT 'CODE'


START   PROC    FAR

	PUSH    DS
	MOV     AX, 0
 	PUSH    AX

	MOV     AX, DSEG
 	MOV     DS, AX
 	MOV     ES, AX

    MOV dx, 2070h
	MOV al, 00h
	OUT dx, al 
	
	MOV dx, 2084h
	OUT dx, al
		
MAIN:
 MOV dx, 2084h 
 IN  al, dx
 MOV dx, 2070h 
 OUT dx, al 
 
 MOV SI, 0	 
 MOV ah, 2ch
 INT 21h
 
 MOV hour, ch
 MOV currTime, ch  
 MOV minute, cl
 
 CMP ch, 0
 JNE standardTime
 ADD ch, 18h
 
 MOV currTime, ch
   
 standardTime:
 CMP ch, 0Ch
 JLE noTimeOffset
 SUB ch, 0Ch
 MOV hour, ch
 
 noTimeOffset:
 MOV ah, 0     
 MOV al, hour   
 MOV bl, 10    
 DIV bl        

 MOV dx, 2030h
 MOV si, ax 
 AND si, 000Fh
 MOV al,NUMBERS[SI]
 OUT dx,al

 MOV al, ah              
 MOV dx, 2031h     
 MOV si, ax 
 AND si, 000Fh
 MOV al,NUMBERS[SI]
 OUT dx,al              

 MOV dx, 2032h      
 MOV al, 01000000b
 OUT dx, al
	
 MOV ah, 0        
 MOV al, minute   
 MOV bl, 10       
 DIV bl             
    
 MOV dx, 2033h     
 MOV si, ax
 AND si, 000Fh 
 MOV al,NUMBERS[SI]
 OUT dx,al
	
 MOV al, ah
 MOV dx, 2034h     
 MOV si, ax
 AND si, 000Fh 
 MOV al,NUMBERS[SI]
 OUT dx,al
 
 MOV ch, currTime
 CMP ch, wakingHour
 JE checkMinutes
 JMP clearASCIILcd
 
 isDrink: MOV ah, 2ch
          INT 21h
          CMP ch, wakingHour 
          JL timeOffset
          timeOffsetDone:
          MOV drinkInterval, ch
          MOV al, wakingHour    
          
          SUB drinkInterval, al
          MOV ax, 0000h
          MOV al, drinkInterval
          MOV bl, 2h
          DIV bl  
          CMP ah, 0
          JE drinkDone 
          JMP clearDotMatrix
    
 drinkMsg: MOV dx,2000h	
	       MOV bx, 0

 drinkMsgLoop: MOV si, 0
	           MOV cx, 5

 dotMatrix: MOV al,Dots[bx][si]
            out dx, al
	        INC si
	        INC dx
            
	        CMP si, 5
	        LOOPNE dotMatrix:

	        ADD bx, 5
	        CMP bx, 25
	        JL drinkMsgLoop
	        JMP MAIN
    
 checkMinutes: CMP cl, 30 
               JLE checkTemp
               CMP isSick, 0
               JE workout
               
 toggleAlarm:  CMP cl, 30 
               JLE alarmOn   
               CMP cl, 30
               JLE drinkDone
               CMP isSick, 0
               JE workout
               JMP clearASCIILcd 
 
 alarmOn: MOV dx, 2040h
          MOV si, 0
          MOV cx, 16
                 
 wakeUp: MOV al, wakeUpMsg[si]
	     OUT dx, al
         INC si
         INC dx
         LOOP wakeUp
         JMP drinkDone
          
 timeOffset: ADD ch, 18h 
             MOV currTime, ch
             JMP timeOffsetDone 
             
 is8Glasses: MOV dx, 2084h 
	         IN  al, dx
	         CMP al, 255   
             JMP ledOn
	         JE clearDotMatrix
  
 clearDotMatrix: MOV dx,2000h
                 MOV bx, 0  
 
 dotMatrixMainloop: MOV si, 0
                    MOV cx, 5

 dotMatrixSubloop: MOV al, 0
                   out dx, al
                   INC si
                   INC dx
                 
                   CMP si, 5
                   LOOPNE dotMatrixSubloop
                 
                   ADD bx, 5
                   CMP bx, 40
                   JL dotMatrixMainloop
                   JMP MAIN 
                   
 clearASCIILcd: MOV DX, 2040h	
	            MOV SI, 0
	            MOV CX, 48

 clearLCD: MOV al, ' '
	       out DX,AL
	       INC SI
	       INC DX

	       LOOP clearLCD
	       JMP isDrink   
	       
 workout: MOV dx, 2040h
          MOV si, 0
          MOV cx, 48
                 
 workoutLoop: MOV al, workoutRoutine[si]
	     OUT dx, al
         INC si
         INC dx
         LOOP workoutLoop
         JMP drinkDone
 	
 ledOn: MOV dx, 2084h
	    IN al, dx
        MOV dx, 2070h
 	    OUT dx, al
	    JMP drinkMsg  
	    
 checkTemp: MOV dx, 2086h	
	        IN  al, dx	  
	
	        MOV dx, 2050h	
	        MOV si, 0
	        MOV cx, 32
	
	        MOV bl, al	
	        MOV bh, 0
        	CMP bl, 4Dh 
        	JG sick  
        	CMP bl, 4Ch
        	JL sick2
        	JMP notSick
        	
 sick: MOV al, sickMsg[SI]
       OUT dx, al
       INC si
       INC dx

       LOOP SICK
       MOV isSick, 1
       JMP toggleAlarm 
       
 sick2: MOV al, sickMsg[SI]
        OUT dx, al
        INC si
        INC dx

        LOOP SICK
        MOV isSick, 1
        JMP toggleAlarm 

 notSick: MOV al, notSickMsg[SI]
          OUT dx, al
          INC si
          INC dx

          LOOP notSick
          MOV isSick, 0
          JMP toggleAlarm
          
 drinkDone: MOV al, wakingHour
            SUB currTime, al
            MOV al, currTime
            CMP al, 0
            JE justWokeUp
            MOV bl, 2h
            DIV bl
            justWokeUp:
            MOV bl, al
            MOV bh, 00
            MOV si, bx
            MOV bl, SWITCH[si]
            MOV dx, 2084h 
            IN  al, dx 
            AND al, bl
            CMP al, SWITCH[si]
            JNE is8Glasses
            JMP clearDotMatrix
	RET
START   ENDP

CSEG    ENDS 

        END    START 

        
        