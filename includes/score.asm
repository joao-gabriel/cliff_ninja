ScoreCalculationRoutine

	lda Score 
	

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

	lda Lives											; [3] +3
	sta PF1												; [6] +3

	lda (ScoreDigit0Location),Y
	and #$f0
	sta Temp

	lda (ScoreDigit1Location),Y
	and #$0f
	ora Temp
	sta PF2												; [12] +3

	lda (ScoreDigit2Location),Y		; [17] +5*
	and #$f0											; [19] +2
	sta PF0												; [22] +3

	lda zero,Y
	and #$f0
	lsr
	sta PF1

	SLEEP 4
	lda #0												; [37] +2
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
