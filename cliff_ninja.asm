	processor 6502
	include includes/vcs.h
	include includes/macro.h

	org $F000

	include includes/cliff_ninja.h

Start
	
	CLEAN_START

	; Set playfield to be mirrored
	lda #%00000001
	sta CTRLPF

	; Set Cliff color
	lda #$F4
	sta COLUPF

	lda #00
	sta COLUP1	
	; Set Cliff data
	lda #$FF
	sta PF0
	sta PF1

	lda #190
	sta CloudsYPos

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

	; Set initial vertical rock position
	lda #183
	sta ObjectFallingYPos

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
	
	; flip animation flag
	lda #1
	eor PlayerAnimationBitmap
	sta PlayerAnimationBitmap	

	lda #7
	sta PlayerAnimationDelay

KeepPlayerBitmap

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


	; Set background color to light blue
	lda #$9C
	sta COLUBK

	ldx #$1A
	sta WSYNC
Position
	dex 
	bne Position
	sta RESP1
	sta WSYNC

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
	;otherwise say that this should go on for 14 lines
	lda #14			
	sta VisiblePlayerLine

SkipActivatePlayer

	;compare Y to the YPosFromBottom
	cpy ObjectFallingYPos
	;if not equal, skip this...
	bne SkipActivateObject 
	;we need to load it with graphic data
	;otherwise say that this should go on for 14 lines
	lda #6			
	sta VisibleObjectLine

SkipActivateObject

	sta WSYNC

	;set player graphic to all zeros for this line, and then see if
	lda #0
	sta GRP0
	sta GRP1

	;if the VisiblePlayerLine is non zero,
	;we're drawing it now!
	;check the visible player line...
	ldx VisiblePlayerLine	

	;skip the drawing if its zero...
	beq FinishPlayer		
	lda colorNinja-1,X
	sta COLUP0

	; Check if player is jumping
	lda PlayerJumping
	beq PlayerIsClimbing
	
	lda jumpingNinja-1,X
	jmp definePlayerBitmap

PlayerIsClimbing

	; Check which climbing player bitmap to show
	lda PlayerAnimationBitmap
	beq ShowPlayerBitmap02

	lda clibingNinja01-1,X
	jmp definePlayerBitmap

ShowPlayerBitmap02

	lda clibingNinja02-1,X	
				
definePlayerBitmap
	sta GRP0		;put that line as player graphic
	dec VisiblePlayerLine 	;and decrement the line count
FinishPlayer




	;if the VisibleObjectLine is non zero,
	;we're drawing it now!
	ldx VisibleObjectLine	

	;skip the drawing if its zero...
	beq FinishObject		

	lda rock-1,X
	sta GRP1		;put that line as player graphic
	dec VisibleObjectLine 	;and decrement the line count
FinishObject



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

	jmp FrameLoop

	; Sprites data
	include includes/bitmaps.inc

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
