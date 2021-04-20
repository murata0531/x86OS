;************************************************************************
;	BIOSでロードされる最初のセクタ
;	
;	プログラム全体を通して、セグメントの値は0x0000とする。
;	(DS==ES==0)
;	
;************************************************************************
		BOOT_LOAD	equ		0x7C00				; ブートプログラムのロード位置

		ORG		BOOT_LOAD						; ロードアドレスをアセンブラに指示

;************************************************************************
;	マクロ
;************************************************************************
%include	"../include/macro.s"

;************************************************************************
;	エントリポイント
;************************************************************************
entry:
		;---------------------------------------
		; BPB(BIOS Parameter Block)
		;---------------------------------------
		jmp		ipl								; IPLへジャンプ
		times	90 - ($ - $$) db 0x90			; 

		;---------------------------------------
		; IPL(Initial Program Loader)
		;---------------------------------------
ipl:
		cli										; // 割り込み禁止

		mov		ax, 0x0000						; AX = 0x0000;
		mov		ds, ax							; DS = 0x0000;
		mov		es, ax							; ES = 0x0000;
		mov		ss, ax							; SS = 0x0000;
		mov		sp, BOOT_LOAD					; SP = 0x7C00;

		sti										; // 割り込み許可

		mov		[BOOT.DRIVE], dl				; ブートドライブを保存

		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; 次の512バイトを読み込む
		;---------------------------------------
		mov		ah, 0x02						; AH = 読み込み命令
		mov		al, 1							; AL = 読み込みセクタ数
		mov		cx, 0x0002						; CX = シリンダ/セクタ
		mov		dh, 0x00						; DH = ヘッド位置
		mov		dl, [BOOT.DRIVE]				; DL = ドライブ番号
		mov		bx, 0x7C00 + 512				; BX = オフセット
		int		0x13							; if (CF = BIOS(0x13, 0x02))
.10Q:	jnc		.10E							; {
.10T:	cdecl	puts, .e0						;	puts(.e0);
		call	reboot							;	reboot(); // 再起動
.10E:											; }

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_2							; ブート処理の第2ステージ

		;---------------------------------------
		; データ
		;---------------------------------------
.s0		db	"Booting...", 0x0A, 0x0D, 0
.e0		db	"Error:sector read", 0

ALIGN 2, db 0
BOOT:											; ブートドライブに関する情報
.DRIVE:			dw	0							; ドライブ番号

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"

;************************************************************************
;	ブートフラグ（先頭512バイトの終了）
;************************************************************************
		times	510 - ($ - $$) db 0x00
		db	0x55, 0xAA

;************************************************************************
;	ブート処理の第2ステージ
;************************************************************************
stage_2:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; 処理の終了
		;---------------------------------------
		jmp		$								; while (1) ; // 無限ループ

		;---------------------------------------
		; データ
		;---------------------------------------
.s0		db	"2nd stage...", 0x0A, 0x0D, 0

;************************************************************************
;	パディング（このファイルは8Kバイトとする）
;************************************************************************
		times (1024 * 8) - ($ - $$)		db	0		; 8Kバイト
