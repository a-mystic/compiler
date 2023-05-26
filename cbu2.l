%{
typedef struct nodeType {	
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;
#define YYSTYPE Node*
#include <string.h>
#include "cbu2.h"
#define MAXSYM	100
#define	MAXSYMLEN	20
char symtbl[MAXSYM][MAXSYMLEN];
int lineno = 1;
int insertsym();
void badCode();
int maxsym = 0;
char s[MAXSYMLEN];
int temp;
Node* MakeNode(int, int);
int annotationCount = 0;
int codeStatusCount = 0;
%}

sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
letter	{eletter}
digit	[0-9]
id		{letter}({letter}|{digit})*

%%
🪄	{ return IF; }
💫 	{ return FOR; }
{ws}	{ codeStatusCount += 1; }
\+  { return ADD; }
\-  { return SUB; }
"//".*  { annotationCount += 1; }
{nl}	{ lineno++; }
♥️  { return ADD; }
♦️ { return SUB; }
♣️ { return MUL; }
♠️ { return DIV; }
=		{ return ASSGN; }
;		{ return STMTEND; }
🌟		{ return START; }
🌙		{
    if(annotationCount > 3) {
        badCode();
    }
    int wsCondition = codeStatusCount / ((lineno - 2) * 2);
    if(wsCondition >= 0 && wsCondition <= 0.8) {
        badCode();
    }
    return END;
}
'<'	{ return LESS; }
'>'	{ return BIGGER; }
👻  { return ERASE; }
var	{ return VAR; }
{id}	{
    temp=insertsym(yytext);
    yylval=MakeNode(ID, temp);
    return ID;
}
-?{digit}+		{
    sscanf(yytext, "%d", &temp);
    yylval=MakeNode(NUM, temp);
    return NUM;
}
.		{ printf("invalid token %s\n", yytext); }
%%

int insertsym(char *s) {
    int i;
    for(i=0;i<maxsym; i++) {
        if(strcmp(s, symtbl[i]) == 0) {
            return i;
        }
    }
    if(i<MAXSYM-1) {
        strcpy(symtbl[maxsym], s);
        maxsym++;
        return maxsym-1;
        }
    else {
        printf("symbol table overflow\n");
        badCode();
    }
	return 0;
}
    
void badCode() {
    printf("bad code\n");
}

int yywrap() {
    return 1;
}
