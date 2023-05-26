%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
typedef struct nodeType {	
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;
#define YYSTYPE Node*
int yylex();
void yyerror(char *s);
#define DEBUG	0
#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2
#define STMTLIST 500
	
int tsymbolcnt = 0;
int errorcnt = 0;
int labelCount = 0;
int forCounter = 0;

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void DFSTree(Node*);
Node* MakeOPTree(int, Node*, Node*);
Node* MakeNode(int, int);
Node* MakeListTree(Node*, Node*);
void codegen(Node* );
void prtcode(int, int);

void dwgen();
int gentemp();
void assgnstmt(int, int);
void numassgn(int, int);
void addstmt(int, int, int);
void substmt(int, int, int);
int insertsym(char *);
%}

%token	ADD SUB ASSGN ID NUM STMTEND START END ID2 MUL DIV IF FOR LESS BIGGER LOOPLABEL ERASE VAR OneCondition

%%
program	: START stmt_list END	{
    if(errorcnt == 0) {
        codegen($2);
        dwgen();
    }
}
		;

stmt_list: 	stmt_list stmt 	{ $$ = MakeListTree($1, $2); }
		|	stmt			{ $$ = MakeListTree(NULL, $1); }
		| 	error STMTEND	{ errorcnt++; yyerrok;}
		;

condition	: term '<' term	{ labelCount++; $$ = MakeOPTree(LESS, $1, $3); }
            | term '>' term	{ labelCount++; $$ = MakeOPTree(BIGGER, $1, $3); }
            | term  { labelCount++; $$ = MakeOPTree(OneCondition, $1, NULL); }
            ;
            
iterateCount    :   NUM  { forCounter = $1->tokenval; $$ = MakeOPTree(LOOPLABEL, $1, NULL); };

stmt	:	VAR ID ASSGN expr STMTEND	{ $2->token = ID2; $$ = MakeOPTree(ASSGN, $2, $4); }
		|   ID ASSGN expr STMTEND	{ $1->token = ID2; $$ = MakeOPTree(ASSGN, $1, $3); }
		|   IF '(' condition ')' '{' stmt_list '}' { $$ = MakeOPTree(IF, $3, $6); }
        |   FOR '(' iterateCount ')' '{' stmt_list '}' { int temp = insertsym("iterate"); yylval = MakeNode(ID, temp); $$ = MakeOPTree(FOR, $3, $6); }
        |   ERASE '{' stmt_list '}'   { $$ = MakeNode(ERASE, $$); }
        ;

expr	: 	'(' expr ')'	{ $$ = $2; }
		|	expr ADD term	{ $$ = MakeOPTree(ADD, $1, $3); }
		|	expr SUB term	{ $$ = MakeOPTree(SUB, $1, $3); }
        |   expr MUL term   { $$ = MakeOPTree(MUL, $1, $3); }
        |   expr DIV term   { $$ = MakeOPTree(DIV, $1, $3); }
		|	term
		;

term	:	ID		{ }
		|	NUM		{ }
		;

%%
void main() {
	yyin = fopen("your path\\inputFromiOS.txt", "r");
	fp=fopen("your path\\a.asm", "w");
	yyparse();
	fclose(yyin);
	fclose(fp);
	if (errorcnt > 0) {
        printf("Failed");
    }
}

void yyerror(char *s) {
	printf("%s (line %d)\n", s, lineno);
}


Node* MakeOPTree(int op, Node* operand1, Node* operand2) {
    Node* newnode;
	newnode = (Node*)malloc(sizeof(Node));
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	return newnode;
}

Node* MakeNode(int token, int operand) {
    Node* newnode;
	newnode = (Node*)malloc(sizeof(Node));
	newnode->token = token;
	newnode->tokenval = operand; 
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node* MakeListTree(Node* operand1, Node* operand2) {
    Node* newnode;
    Node* node;
	if (operand1 == NULL) {
		newnode = (Node*)malloc(sizeof(Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
        while (node->brother != NULL) {
            node = node->brother;
        }
		node->brother = operand2;
		return operand1;
		}
}

void codegen(Node* root) {
	DFSTree(root);
}

void DFSTree(Node* n) {
    if (n==NULL) {
        return;
    }
	DFSTree(n->son);
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
}

void prtcode(int token, int val) {
	switch (token) {
	case ID:
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		break;
	case ID2:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case NUM:
		fprintf(fp, "PUSH %d\n", val);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
    case MUL:
        fprintf(fp, "*\n");
        break;
    case DIV:
        fprintf(fp, "/\n");
        break;
	case ASSGN:
		fprintf(fp, ":=\n");
		break;
    case LESS:
        fprintf(fp, "-\n");
        fprintf(fp, "GOPLUS OUT%d\n", labelCount);
        break;
    case BIGGER:
        fprintf(fp, "-\n");
        fprintf(fp, "GOMINUS OUT%d\n", labelCount);
        break;
    case OneCondition:
        fprintf(fp, "PUSH 1\n");
        fprintf(fp, "-\n");
        fprintf(fp, "GOMINUS OUT%d\n", labelCount);
        break;
    case IF:
        fprintf(fp, "LABEL OUT%d\n", labelCount);
        break;
    case LOOPLABEL:
        fprintf(fp, "LVALUE iterate\n");
        fprintf(fp, "PUSH 1\n");
        fprintf(fp, ":=\n");
        fprintf(fp, "LABEL LOOPLABEL%d\n", forCounter);
        fprintf(fp, "RVALUE iterate\n");
        fprintf(fp, "PUSH %d\n", forCounter);
        fprintf(fp, "-\n");
        fprintf(fp, "GOPLUS OUTLOOP%d\n", forCounter);
        break;
    case FOR:
        fprintf(fp, "LVALUE iterate\n");
        fprintf(fp, "RVALUE iterate\n");
        fprintf(fp, "PUSH 1\n");
        fprintf(fp, "+\n");
        fprintf(fp, ":=\n");
        fprintf(fp, "GOTO LOOPLABEL%d\n", forCounter);
        fprintf(fp, "LABEL OUTLOOP%d\n", forCounter);
        break;
    case ERASE:
        fprintf(fp, "GOTO ENDLABEL\n");
        break;
    case STMTLIST:
	default:
		break;
	};
}

void dwgen() {
    fprintf(fp, "LABEL ENDLABEL\n");
    fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");
    for(int i=0; i<maxsym; i++) {
        fprintf(fp, "DW %s\n", symtbl[i]);
    }
	fprintf(fp, "END\n");
}
