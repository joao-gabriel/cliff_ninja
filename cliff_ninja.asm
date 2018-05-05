	processor 6502
	include includes/vcs.h
	include includes/macro.h

	org $F000

	include includes/cliff_ninja.h

Start
	
	CLEAN_START

	; Set background color to light blue
	lda #$9C
	sta COLUBK

	; Set playfield to be mirrored
	lda #%00000001
	sta CTRLPF

	; Set Cliff color
	lda #$F4
	sta COLUPF

	; Set Cliff data
	lda #$FF
	sta PF0
	sta PF1

	; Set Initial Player Y Position from bottom
	lda #80
	sta YPosFromBottom

	; Set Player Animation Delay (in frames)
	lda #7
	sta PlayerAnimationDelay

	; Player starts Jumping and Facing Right
	lda #1
	sta PlayerJumping
	sta PlayerFacingRight

	; Set initial movement for player
	lda #%11100000
	sta HMP0

	; Set initial bitmap for player
	lda #1
	sta PlayerWhichBitmap

	; Set all score digits to zero
	lda #<zero
  sta ScoreDigit0
  lda #>zero
  sta ScoreDigit0 + 1

FrameLoop

	lda #2
	sta VSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC
	lda #43
	sta TIM64T
	lda #0
	sta VSYNC

	; Check if player is facing right
	lda PlayerFacingRight
	beq PlayerIsNotFacingRight

	lda #%00001000

PlayerIsNotFacingRight

	sta REFP0

	; Check if player is climbing or jumping
	; That is, check if player has collided with the cliff
	lda #%10000000
	and CXP0FB
	beq NoCollision

	lda #0

	; Unset 'PlayerJumping' flag
	sta PlayerJumping

	; Stops player
	sta HMP0

	; Player Climbing Animation
	dec PlayerAnimationDelay
	bne KeepPlayerBitmap

	lda PlayerWhichBitmap
	eor #1
	sta PlayerWhichBitmap
	lda #7
	sta PlayerAnimationDelay

KeepPlayerBitmap

	; Check which player bitmap should be shown
	lda PlayerWhichBitmap
	bne PlayerBitmap2

  lda #<climbingNinja01
  sta PlayerBitmapLocation
  lda #>climbingNinja01
  sta PlayerBitmapLocation + 1
  jmp PlayerBitmapChooseEnd

PlayerBitmap2

  lda #<climbingNinja02
  sta PlayerBitmapLocation
  lda #>climbingNinja02
  sta PlayerBitmapLocation + 1

PlayerBitmapChooseEnd

	; Check if user pressed left
	lda #%01000000	
	bit SWCHA
	bne SkipMoveLeft

	; Player can only move left if it was facing right before
	lda PlayerFacingRight
	beq SkipMoveLeft

	lda #%00100000
	sta HMP0

	; Unset PlayerFacingRight
	lda #0
	sta PlayerFacingRight	

SkipMoveLeft

	; Check if user pressed right
	lda #%10000000
	bit SWCHA
	bne SkipMoveRight

	; Player can only move right if it was facing left before
	lda PlayerFacingRight
	bne SkipMoveRight

	lda #%11100000
	sta HMP0

	lda #1
	sta PlayerFacingRight
	
SkipMoveRight

	jmp PlayerIsNotJumping
	
NoCollision

	; set 'PlayerIsJumping' flag
	lda #1 
	sta PlayerJumping

PlayerIsNotJumping

	sta CXCLR
	sta WSYNC	
	sta HMOVE

WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd

	ldy #184
	sta WSYNC
	sta VBLANK

ScanlineLoop

	sta WSYNC

	lda PlayerBitmapBuffer
	sta GRP0

  lda #0
  sta PlayerBitmapBuffer

	cpy YPosFromBottom
	bne SkipActivatePlayer 
	lda #14			
	sta VisiblePlayerLine

SkipActivatePlayer

  tya
  tax
	ldy VisiblePlayerLine

	beq FinishPlayer		
	lda colorNinja-1,Y
	sta COLUP0

  lda (PlayerBitmapLocation),Y
	sta PlayerBitmapBuffer
	dec VisiblePlayerLine
FinishPlayer

  txa
  tay
	dey
	bne ScanlineLoop

	sta WSYNC

	lda #0
	sta PF0
	sta PF1
	sta PF2
	sta WSYNC

	ldy #4

ScoreScanlineLoop

	lda (ScoreDigit0),Y
	sta PF0

	sta WSYNC

	dey
	bne ScoreScanlineLoop

	lda (ScoreDigit0),Y
	sta PF0

	sta WSYNC

	lda #0
	sta PF0
	sta PF2

	sta WSYNC

	lda #$ff
	sta PF0

	; Overscan
	lda #2
	sta WSYNC
	sta VBLANK
	ldx #30
OverScanWait
	sta WSYNC
	dex
	bne OverScanWait

	jmp FrameLoop

	; Bitmaps data
	include includes/bitmaps.inc

colorNinja
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$00;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$FC;
        .byte #$FC;
        .byte #$43;

	org $FFFC
	.word Start
	.word Start
