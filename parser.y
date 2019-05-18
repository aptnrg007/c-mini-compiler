%{
	#include<stdio.h>
	#include"y.tab.h"
	#include "lex.yy.c"
	#include "symtab.h"
	extern int line ;
	extern int scope;
	int yylex();
	int yyerror(char *) ;
	int temp ;
	int t ;
	int flag=0;
	void install (char *sym_name){
		sr *s ;
		s = getsym(sym_name) ;
		if(s == 0)
		s = putsym(sym_name, temp) ; //here
		else{
		//errors++ ;
		printf("%s is already defined, redefined @ line %d\n", sym_name, line) ;

		}
	}
	void context_check(char *sym_name){
		if(getsym(sym_name) == 0){
			printf("%s is an undeclared identifier @ line %d\n", sym_name, line) ;
			flag=1;
		}else{
			flag=0;
		}
	}
	void type_check(char *type, int type_2){
		int type_1 ;
		if(strcmp(type, "int") == 0)
			type_1 =  3 ;
		else if(strcmp(type, "float") == 0)
			type_1 = 4 ;
		else type_1 = 2 ;
		if(type_1 != type_2)
			printf("type mismatch @ line %d\n", line) ;
	}

%}

%union {int ival ; char *id; float fval;}
%token INT FLOAT CHAR VOID DOUBLE BOOL FOR IF ELSE CLASS ACCESS USING NAMESPACE STD
%token <id> ID
%token NUM STRING FNUM 
%token INCLUDE RETURN
%token GE EE LE NE LT GT AND OR NOT INCR DECR

%left '+' '-' '*' '/'
%right '=' '^'


%start start
%%

start:
      INCLUDE start | function start |  class start | nam start | declaration start |
      ;

nam : USING NAMESPACE STD ';' ;

class :
		CLASS ID '{' classbdy '}'  classobj ';'
		 ; 

classbdy :
		ACCESS ':' classbdy | declaration classbdy | function classbdy | ;

classobj : ID ',' classobj | ID | ;

function:
	  type ID '(' arg_list ')'  compound_statement  |
	  type ID '(' ')'  compound_statement | 
	  type ID '(' type_list ')' ';' |
	  type ID ':'':' ID '(' arg_list ')'  compound_statement |
	  type ID ':'':' ID '(' ')'  compound_statement 
	  ;

arg_list : arg ',' arg_list | arg ;

type_list : type ',' type_list | type ;

arg:
	type ID | 
	;

compound_statement:
	  '{' statement_list '}' |
	  '{' '}'
	  ;

statement_list:
		statement | 
		statement statement_list
		;

statement:
		declaration |
		assignment |
		array |
		for |
		if_else|
		function_call  |
		RETURN expression ';'

		;


declaration:
		type identifier_list ';' ;

identifier_list:
		ID ',' identifier_list {install($1) ;}| ID {install($1) ;}
		;

assignment:
		ID '=' expression ';' {context_check($1) ; sr *ss = getsym($1) ;  if(flag==0){type_check(ss->type, t);}}|
		type ID '=' expression ';'	{install($2);sr *ss = getsym($2) ;if(flag==0)type_check(ss->type, t);} 
		;


for:
		FOR '(' assignment  expression  ';' expression ')' compound_statement |

		FOR '(' assignment  expression  ';' expression ')' statement |

		FOR '(' ';' expression ';' ')' compound_statement |

		FOR '(' ';' ';' ')' compound_statement |

		FOR '(' assignment ';' ')' compound_statement | 

		FOR '(' assignment expression ';' ')' compound_statement |

		FOR '(' ';' expression ';' expression ')' compound_statement |

		FOR '(' assignment ';'expression ')' compound_statement 


		;

if_else:
		IF '(' expression ')' compound_statement |
		if_else ELSE IF '('expression ')' compound_statement |
		
		if_else ELSE compound_statement 
		;


expression : expression AND rel_exp | expression OR rel_exp | NOT rel_exp | rel_exp ;

rel_exp :	rel_exp relop add_expression | add_expression ;

add_expression : add_expression '+' mul_expression | add_expression '-' mul_expression | mul_expression ;

mul_expression : mul_expression '*' cast_exp |  mul_expression '/' cast_exp | cast_exp ;

cast_exp : unary_exp | '(' type ')' cast_exp ;

unary_exp : exp | INCR exp | DECR exp | exp INCR | exp DECR | unary_op exp ;

unary_op : '-' | '+' | '&' | '!' ;

exp : base | exp '(' ')' | exp '(' identifier_list ')' ;

base : ID {context_check($1) ;sr *ss = getsym($1); if(!strcmp(ss->type, "int")) t = 3; else t = 4 ;}| NUM {t = 3;} | FNUM  {t = 4;}| STRING {t = 2;} | '(' expression')';

relop : LE | GE | GT | LT | EE  | NE ;

array:
		type ID '[' NUM ']' ';' {install($2) ;}      |
		type ID '[' NUM ']' '=' STRING ';' {install($2) ;}      |
		ID '[' NUM ']' '=' STRING ';' {context_check($1) ;}|
		type ID '[' NUM ']' '=' NUM ';' {install($2) ;}      |
		ID '[' NUM ']' '=' NUM ';' {context_check($1) ;}  |
		type ID '[' ']' '=' STRING ';' {install($2) ;} 
		;

function_call:
		ID '(' identifier_list ')' ';'
		ID '(' ')' ';'
		;

type:
 		INT {temp = 3;}| VOID {temp = 1;}| CHAR {temp = 2;}| FLOAT  {temp = 4;}| DOUBLE {temp = 4;}| BOOL{temp = 3;}
 		;

%%



int main(int argc, char *argv[]){
    yyin=fopen(argv[1],"r");
    printf("\n\n\n*************** begin ***************\n\n\n");

    yyparse();

    printf("\n\n\n******************* parsing complete ************************\n\n\n");
    
    printf("******************symbol table*******************\n\n");
    printf("name \t\t type \t\t lineno\t\t scope \n");
    printsym();
    fclose(yyin);
    return 0;
}

int yyerror(char *s){
	
	printf("at line : %d %s\n",line,s);
	
}			