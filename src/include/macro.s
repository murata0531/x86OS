;************************************************************************
; 関数呼び出し用マクロ
;
; 使い方：
;	cdecl	func [, param1[, param2[, ...]]]
;
;************************************************************************

%macro cdecl 1-*.nolist

    %rep %0 - 1
        push    %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1

        call    %1

    %if 1 < %0
        add     sp,(__BITS__ >> 3) * (%0 - 1)
    %endif

%endmacro

;************************************************************************
;	構造体
;************************************************************************

;-----------------------------------------------
;	ドライブパラメータ
;-----------------------------------------------
struc drive
		.no				resw	1				; ドライブ番号
		.cyln			resw	1				; C:シリンダ
		.head			resw	1				; H:ヘッド
		.sect			resw	1				; S:セクタ
endstruc