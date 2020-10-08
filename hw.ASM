format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Input size of vector: ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d] = ', 0
        strScanInt   db '%d', 0
        strSumValue  db 'Summa = %d', 10, 0
        strOut       db 'Arrray: ', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        sum          dd 0
        i            dd ?
        tmp          dd ?
        tmp2         dd ?
        tmpStack     dd ?
        vec          rd 100
        newvec       rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
        call CopyVector
        push strOut
        call [printf]
        call PrintVector
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jle  FinishError
        cmp eax, 100
        jg FinishError
        jmp getVector
;If vec_size <= 0 || vec_size > 100
FinishError:
        push [vec_size]
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
CopyVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec
        xor edx, edx
        xor eax, eax
VectorCopyLoop:
        cmp ecx, [vec_size]
        je endCopyVector      ; to end of loop

        cmp dword [ebx], 0
        jle CopyElement
        cmp edx, 0
        je ChangeFlag
        jmp CopyElement



ChangeFlag:
        mov edx, 1
        inc ecx
        add ebx, 4
        jmp VectorCopyLoop


CopyElement:
        mov [tmp], ecx
        mov ecx, dword[ebx]
        mov [newvec + eax*4], ecx
        mov ecx, [tmp]
        inc ecx
        inc eax

        add ebx, 4
        jmp VectorCopyLoop

endCopyVector:
        neg edx
        add [vec_size], edx
        ret

;----------------------------------------------------------------------------
PrintVector:
        xor ecx, ecx
        mov ebx, newvec
VectorLoop:
        cmp ecx, [vec_size]
        je endPrintVector
        mov [tmp], ecx
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]
        add esp, 12
        mov ecx, [tmp]
        inc ecx
        add ebx, 4
        jmp VectorLoop

endPrintVector:
        ret
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'