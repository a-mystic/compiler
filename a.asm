LVALUE a
PUSH 3
:=
LVALUE b
RVALUE a
PUSH 3
+
:=
LVALUE size
RVALUE b
PUSH 4
-
:=
LVALUE height
RVALUE size
PUSH 4
*
:=
LVALUE height
RVALUE height
PUSH 2
/
:=
PUSH 0
PUSH 1
-
GOMINUS OUT1
LVALUE height
PUSH 7
:=
LVALUE width
PUSH 10
:=
LABEL OUT1
LVALUE time
PUSH 2
:=
PUSH 9
LVALUE iterate
PUSH 1
:=
LABEL LOOPLABEL9
RVALUE iterate
PUSH 9
-
GOPLUS OUTLOOP9
LVALUE time
RVALUE time
PUSH 2
*
:=
LVALUE iterate
RVALUE iterate
PUSH 1
+
:=
GOTO LOOPLABEL9
LABEL OUTLOOP9
GOTO ENDLABEL
LABEL ENDLABEL
HALT
$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --
DW a
DW b
DW size
DW height
DW width
DW time
DW iterate
DW checkIgnore
END
