	processor 6502
	include vcs.h
	include macro.h

	org $F000

YPosFromBottom = $80;
VisiblePlayerLine = $81;
PlayerAnimationDelay = $82;

PlayerBitmapFlags = $83;
; PlayerBitmapFlags
; D0 = 0 -> show climbing bitmap01 / D0 = 1 -> show climbing bitmap02
; D1 = 0 -> player facing left / D1 = 1 -> player facing right
; D2 = 0 -> player climbing / D2 = 1 -> player jumping
; D3 = 0 -> player not attacking / D3 = 1 -> player attacking

PlayerIsFacingRight = #%00000010;
PlayerIsJumping = #%00000100;

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

	; Set the PlayerBitmapFlags
	; Player is Jumping (D2) and Facing Right (D1)
	lda #%00000110
	sta PlayerBitmapFlags

	; Set initial movement for player
	lda #%11100000
	sta HMP0

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
	lda PlayerIsFacingRight
	and PlayerBitmapFlags
	beq PlayerIsNotFacingRight

	lda #%00001000

PlayerIsNotFacingRight

	sta REFP0

	; Check if player is climbing or jumping
	; That is, check if player has collided with the cliff
	lda #%10000000
	and CXP0FB 
	beq NoCollision

	; Unset 'PlayerIsJumping' flag
	lda #%11111011
	and PlayerBitmapFlags 
	sta PlayerBitmapFlags

	sta HMCLR

	; Player Climbing Animation
	dec PlayerAnimationDelay 
	bne KeepPlayerBitmap
	
	; flip animation flag
	lda #%00000001
	and PlayerBitmapFlags
	beq DontFlip
	
	lda #$00
	sta COLUBK

	lda #%00000001
	ora PlayerBitmapFlags
	sta PlayerBitmapFlags

	jmp DoneFlipCheck
	
DontFlip

	lda #$F0
	sta COLUBK

	lda #%11111110
	and PlayerBitmapFlags
	sta PlayerBitmapFlags

DoneFlipCheck
	
	lda #7
	sta PlayerAnimationDelay

KeepPlayerBitmap

	; Check if user pressed left
	lda #%01000000	
	bit SWCHA
	bne SkipMoveLeft
	
	lda #%00100000
	sta HMP0

	; Unset PlayerIsFacingRight
	lda #%11111101
	and PlayerBitmapFlags
	sta PlayerBitmapFlags

SkipMoveLeft

	; Check if user pressed right
	lda #%10000000
	bit SWCHA
	bne SkipMoveRight

	lda #%11100000
	sta HMP0

	lda PlayerIsFacingRight
	ora PlayerBitmapFlags
	sta PlayerBitmapFlags
	
SkipMoveRight

	jmp PlayerIsNotJumping
	
NoCollision

	; set 'PlayerIsJumping' flag
	lda PlayerIsJumping
	ora PlayerBitmapFlags 
	sta PlayerBitmapFlags

	
PlayerIsNotJumping	
	sta CXCLR
	sta WSYNC	
	sta HMOVE

WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd

	ldy #191
	sta WSYNC
	sta VBLANK

ScanlineLoop

	;compare Y to the YPosFromBottom
	cpy YPosFromBottom
	;if not equal, skip this...
	bne SkipActivatePlayer 
	;we need to load it with graphic data
	;otherwise say that this should go on for 16 lines
	lda #14			
	sta VisiblePlayerLine

SkipActivatePlayer

	sta WSYNC

	;set player graphic to all zeros for this line, and then see if
	lda #0
	sta GRP0

	;if the VisiblePlayerLine is non zero,
	;we're drawing it now!
	;check the visible player line...
	ldx VisiblePlayerLine	

	;skip the drawing if its zero...
	beq FinishPlayer		
	lda colorNinja-1,X
	sta COLUP0

	; Check if player is jumping
	;lda #%00000100
	;and PlayerBitmapFlags
	;beq PlayerIsClimbing	

	;lda jumpingNinja-1,X

	;jmp definePlayerBitmap

PlayerIsClimbing

	; Check which climbing player bitmap to show
	lda #00000001
	and PlayerBitmapFlags
	beq ShowPlayerBitmap02

	lda clibingNinja01-1,X
	jmp definePlayerBitmap

ShowPlayerBitmap02

	lda clibingNinja02-1,X	;otherwise, load the correct line from BigHeadGraphic
				;section below... it's off by 1 though, since at zero
				;we stop drawing
definePlayerBitmap
	sta GRP0		;put that line as player graphic
	dec VisiblePlayerLine 	;and decrement the line count
FinishPlayer

	dey
	bne ScanlineLoop

	; Overscan
	lda #2
	sta WSYNC
	sta VBLANK
	ldx #30
OverScanWait
	sta WSYNC
	dex
	bne OverScanWait

	jmp  FrameLoop

	; Sprites data
	include bitmaps.inc

colorNinja
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$00;
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
