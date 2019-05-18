%{
	#include<stdio.h>
	#include"y.tab.h"
	#include "lex.yy.c"
	extern int line ;
	int yylex();
	int yyerror(char *) ;
	char *dummy;
		
	struct node {
		struct node * left;
		struct node *right ;
		struct node *another ;
		char *token ;
	};

	struct node *mknode(struct node *left,struct node *right,struct node *another,char *token);
	void printtree(struct node *tree);


%}

%union {int ival ; char *id; float fval;struct node *nd;}

%type <nd> function compound_statement statement_list statement assignment expression rel_exp add_expression mul_expression unary_exp cast_exp exp base declaration if_else identifier_list type for for_args start nam

%token INT FLOAT CHAR VOID DOUBLE BOOL FOR IF ELSE CLASS ACCESS USING NAMESPACE STD
%token <id> ID
%token NUM STRING FNUM 
%token INCLUDE RETURN
%token <id> GE EE LE NE LT GT AND OR NOT INCR DECR

%left '+' '-' '*' '/'
%right '=' '^'


%start start
%%

start:
      INCLUDE start{$$=NULL;}|
      class start {$$=NULL;}|
      function start{printf("printing tree \n\n");printtree($1);} |
      declaration start {$$=NULL;}|
      nam start{$$=NULL;} |
      {$$=NULL;};



nam : USING NAMESPACE STD ';' {$$=NULL;};

class :
		CLASS ID '{' classbdy '}'  classobj ';'
		 ; 

classbdy :
		ACCESS ':' classbdy | declaration classbdy | function classbdy | ;

classobj : ID ',' classobj | ID | ;


function:
	  type ID '(' arg_list ')'  compound_statement {$$=$6;} |
	  type ID '(' ')'  compound_statement {$$=$5;}|
	  type ID ':'':' ID '(' arg_list ')'  compound_statement {$$=$9;}|
	  type ID ':'':' ID '(' ')'  compound_statement{$$=$8;}
	  ;

arg_list : arg ',' arg_list | arg ;

arg:
	type ID | 
	;

compound_statement:
	  '{' statement_list '}' {$$=$2;}
	  ;

statement_list:
		statement {$$=$1;} | 
		statement statement_list {$$ = mknode($1,$2,NULL,"stmt_list");}
		;

statement:
		
		assignment {$$=$1;} |
		declaration {$$=$1;}|
		if_else {$$=$1;}|
		for {$$=$1;}|
		expression {$$=$1;}|
		RETURN expression  ';'{$$ = mknode($2,NULL,NULL,"return");}

		;

for:
		FOR '(' for_args')' compound_statement {$$= mknode($3,$5,NULL,"for");}|

		FOR '(' for_args ')' statement {$$= mknode($3,$5,NULL,"for");}
		;

for_args :
			assignment  expression  ';' expression {$$ =mknode($1,$2,$4,"for_args");} 
			;


if_else:
		IF '(' expression ')' compound_statement {$$ = mknode($3,$5,NULL,"if");}|
		if_else ELSE IF '('expression ')' compound_statement {$$ = mknode($1,$5,$7,"else if");} |
		
		if_else ELSE compound_statement {$$ = mknode($1,$3,NULL,"else");}
		;



declaration:
		type identifier_list  ';'{$$ =mknode($1,$2,NULL,"dec");} ;

identifier_list:
		base ',' identifier_list {$$=mknode($1,$3,NULL,",");} | base{$$=$1;}
		;

assignment:
		base '=' expression ';' {$$ = mknode($1,$3,NULL,"=");}	|
		type base '=' expression ';'{$$ = mknode($2,$4,NULL,"=");}
		;



expression : expression AND rel_exp {$$ = mknode($1,$3,NULL,"and");} | expression OR rel_exp{$$ = mknode($1,$3,NULL,"or");} |  rel_exp{$$=$1;} ;

rel_exp :	rel_exp relop add_expression {$$ = mknode($1,$3,NULL,dummy);} | add_expression {$$=$1;};

add_expression : add_expression '+' mul_expression {$$ = mknode($1,$3,NULL,"+");}| add_expression '-' mul_expression {$$ = mknode($1,$3,NULL,"-");}| mul_expression {$$=$1;};

mul_expression : mul_expression '*' cast_exp {$$ = mknode($1,$3,NULL,"*");}|  mul_expression '/' cast_exp {$$ = mknode($1,$3,NULL,"/");}| cast_exp {$$=$1;};

cast_exp : unary_exp {$$=$1;} ;

unary_exp : exp {$$=$1;}| INCR exp {$$= mknode(NULL,$2,NULL,"++");} | DECR exp{$$= mknode(NULL,$2,NULL,"--");} | exp INCR{$$= mknode($1,NULL,NULL,"++");} | exp DECR {$$= mknode($1,NULL,NULL,"--");}| unary_op exp {$$= mknode(NULL,$2,NULL,dummy);} ;

unary_op : '-'{dummy = "-";} | '+' {dummy = "-";}| '&' {dummy = "-";}| '!' {dummy = "-";};

exp : base {$$=$1;}  ;

base : ID {char *name=$1;$$= mknode(NULL,NULL,NULL,name);}| NUM {$$= mknode(NULL,NULL,NULL,"num");}| FNUM {$$= mknode(NULL,NULL,NULL,"fnum");} | STRING {$$= mknode(NULL,NULL,NULL,"string");}| '(' expression')'{$$=$2;};

relop : LE {dummy = "<=";} | GE {dummy = ">=";}| GT {dummy = ">";}| LT{dummy = "<";} | EE {dummy = "==";} | NE {dummy = "!=";};

type:
 		INT{$$=mknode(NULL,NULL,NULL,"int");}| VOID{$$=mknode(NULL,NULL,NULL,"void");} | CHAR {$$=mknode(NULL,NULL,NULL,"char");}| FLOAT {$$=mknode(NULL,NULL,NULL,"float");} | DOUBLE {$$=mknode(NULL,NULL,NULL,"double");}| BOOL{$$=mknode(NULL,NULL,NULL,"bool");}
 		;

%%



int main(int argc, char *argv[]){
    yyin=fopen(argv[1],"r");
    printf("\n\n\n*************** begin ***************\n\n\n");

    yyparse();

    printf("\n\n\n******************* parsing complete ************************\n\n\n");
    fclose(yyin);
    return 0;
}

int yyerror(char *s){
	
	printf("at line : %d %s\n",line,s);
	
}			



struct node *mknode(struct node *left,struct node *right,struct node *another, char *token)
{
  // printf("Making NODE\n");
  /* malloc the node */
  struct node *newnode = (struct node *)malloc(sizeof(struct node));
  char *newstr = (char *)malloc(strlen(token)+1);
  strcpy(newstr, token);
  newnode->left = left;
  newnode->right = right;
  newnode->another =another;
  newnode->token = newstr;
  return newnode;
}

void printtree(struct node *tree)
{
  //printf("Printing tree");

  if (tree->left || tree->right || tree->another)
    printf("(");

  printf(" %s ", tree->token);

  if (tree->left)
    printtree(tree->left);
  if (tree->right)
    printtree(tree->right);
  if (tree->another)
    printtree(tree->another);

  if (tree->left || tree->right || tree->another)
    printf(")");
}



/*void printtree(struct node *tree)
{
  if(tree!=NULL){
  	printf("(");
  	printtree(tree->left);
  	printf("%s   ",tree->token);
  	printtree(tree->right);
  	printf(")");

  }
}

*/