ScoreIncrementRoutine

	sed
	clc
	lda Score
	adc #$01
	sta Score
	lda Score + 1
	adc #$00
	sta Score + 1
	cld

	rts

ScoreCalculationRoutine

	lda Score
	; isolate ones
	and #$0f
	sta Temp
	; multiplies it by 5 to find correct bitmap on lookup table
	clc
	asl
	asl
	adc Temp
	adc #<zero
	sta ScoreDigit0Location
	; Check if increments MSB
	lda #>zero
	adc #0
	sta ScoreDigit0Location + 1

	lda Score
	; isolate tens
	and #$f0
	lsr
	lsr
	lsr
	lsr
	sta Temp
	; multiplies it by 5 to find correct bitmap on lookup table
	clc
	asl
	asl
	adc Temp
	adc #<zero
	sta ScoreDigit1Location
	; Check if increments MSB
	lda #>zero
	adc #0
	sta ScoreDigit1Location + 1

	lda Score + 1
	; isolate ones
	and #$0f
	sta Temp
	; multiplies it by 5 to find correct bitmap on lookup table
	clc
	asl
	asl
	adc Temp
	adc #<zero
	sta ScoreDigit2Location
	; Check if increments MSB
	lda #>zero
	adc #0
	sta ScoreDigit2Location + 1
	
	rts


ScoreDisplayRoutine	

	lda #$ff
	sta PF0
	sta PF1
	sta PF2
	sta WSYNC

	lda #0
	sta PF0
	sta PF1
	sta PF2
	sta CTRLPF

	ldy #4

ScoreScanlineLoop

	sta WSYNC

	lda Lives
	sta PF1

	lda (ScoreDigit1Location),Y
	and #$f0
	sta Temp

	lda (ScoreDigit2Location),Y
	and #$0f
	ora Temp
	sta PF2

	lda (ScoreDigit0Location),Y
	and #$f0
	sta PF0

	lda zero,Y
	and #$f0
	lsr
	sta PF1

	SLEEP 4
	lda #0
	sta PF1
	sta PF0
	sta PF2
	
	dey
	bpl ScoreScanlineLoop

	sta WSYNC

	lda #0
	sta PF0
	sta PF1
	sta PF2

	sta WSYNC

	lda #$ff
	sta PF1
	sta PF0
	sta PF2

	lda #1
	sta CTRLPF

	sta WSYNC

	rts
