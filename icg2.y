%{
	#include<stdio.h>
	#include"y.tab.h"
	#include "lex.yy.c"
	extern int line ;
	int yylex();
	int yyerror(char *) ;
	
	char st[100][10];
	int top=0;
	int i_ = 0;
	char si[20];

	char temp[2]="t";

	int label[20];
	int lnum=0;
	int ltop=0;
	int start=1;
	char ss[20];
	char l[1] = "L";
	
	void push();
	void codegen();
	void codegen_assign();
	void codegen_umin();
	void pushid(char *name);
	void lab1();
	void lab2();
	void lab3();
	void lab1f();
	void lab2f();
	void lab3f();
	void lab4f();
	void my_itoa(int num, char temp1[20]);
	void print_INT_CODE();
	void print_OPT_CODE();
	void copy_prop();
	int isDigit(char t[100]);
	void copy();







	struct OPT
{
	char op[10];
	char arg1[10];
	char arg2[10];
	char result[10];
};

struct OPT QIC[100];
struct OPT OPT[100];
int ind = 0;
int oind =0;

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
		ID ',' identifier_list | ID 
		;

assignment:
		ID {pushid($1);} '='{push();} expression{codegen_assign();} ';' |
		type ID {pushid($2);}'='{push();} expression {codegen_assign();}';'	
		;


for:
		FOR '(' assignment{lab1f();}  expression{lab2f();}  ';' expression{lab3f();} ')' compound_statement{lab4f();} 

		;

if_else:
		IF '(' expression ')'{printf("\n");lab1();} compound_statement {lab2();} |
		if_else ELSE IF '('expression ')'{lab1();}  compound_statement {lab2();}|
		
		if_else ELSE compound_statement {lab3();}
		;


expression : expression  AND {push();} rel_exp {codegen();}
			| expression OR{push();} rel_exp {codegen();}
			| NOT rel_exp 
			| rel_exp ;

rel_exp :	rel_exp relop add_expression{codegen();} 
			| add_expression ;

add_expression : add_expression  '+' {push();}  mul_expression  {codegen();}
				| add_expression '-'{push();} mul_expression  {codegen();}
				| mul_expression ;

mul_expression : mul_expression '*' {push();} cast_exp  {codegen();}
				|  mul_expression '/'{push();}  cast_exp  {codegen();}
				| cast_exp ;

cast_exp : unary_exp 
			| '(' type ')' cast_exp ;

unary_exp : exp | INCR {push();} exp{codegen_umin();} | DECR{push();} exp{codegen_umin();} | exp INCR{push();}{codegen_umin();} | exp DECR{push();}{codegen_umin();} | unary_op exp {codegen_umin();};

unary_op : '-' {push();} | '+'{push();} | '&'{push();} | '!'{push();} ;

exp : base | exp '(' ')' | exp '(' identifier_list ')' ;

base : ID {pushid($1);}
		| NUM  {push();}
		| FNUM  {push();}
		| STRING  
		| '(' expression')';

relop : LE{push();} | GE{push();} | GT{push();} | LT{push();} | EE{push();}  | NE{push();} ;

array:
		type ID '[' NUM ']' ';'       |
		type ID '[' NUM ']' '=' STRING ';'|
		ID '[' NUM ']' '=' STRING ';' |
		type ID '[' NUM ']' '=' NUM ';'    |
		ID '[' NUM ']' '=' NUM ';'   |
		type ID '[' ']' '=' STRING ';' 
		;

function_call:
		ID '(' identifier_list ')' ';'
		ID '(' ')' ';'
		;

type:
 		INT| VOID | CHAR | FLOAT  | DOUBLE | BOOL
 		;

%%



int main(int argc, char *argv[]){
    yyin=fopen(argv[1],"r");
    printf("\n\n\n*************** begin ***************\n\n\n");

    yyparse();

    printf("\n\n\n******************* parsing complete ************************\n\n\n");
    
    
    print_INT_CODE();

    copy();
    copy_prop();
    print_OPT_CODE();


    fclose(yyin);
    return 0;
}

int yyerror(char *s){
	
	printf("at line : %d %s\n",line,s);
	
}			

void push()
{
//printf("pushing YYtext is %s\n",yytext);
strcpy(st[++top],yytext);
}


void pushid(char *name)
{
//printf("pushing yylval is %s\n",name);
strcpy(st[++top],name);
}



void codegen()
{
strcpy(temp,"t");
my_itoa(i_ , si);
strcat(temp, si);
strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , st[top-1]);
strcpy(QIC[ind].arg1, st[top-2]);
strcpy(QIC[ind].arg2 , st[top]);
ind++;
printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
top-=2;
strcpy(st[top],temp);
i_++;
}


void codegen_umin()
{
strcpy(temp,"t");


my_itoa(i_ , si);
strcat(temp, si);
strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , st[top-1]);
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;
printf("%s = %s%s\n",temp,st[top-1],st[top]);
top--;
strcpy(st[top],temp);
i_++;
}

void codegen_assign()
{
strcpy(QIC[ind].result , st[top-2]);
strcpy(QIC[ind].op , "=");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;

printf("%s = %s\n",st[top-2],st[top]);
top-=2;
}


void printStack()
{
int i = top;
printf("Printing Curr stack\n");
while(i>-1){
	printf("%s \n",st[i]);
	i = i-1;
}
}



void lab1()   //Create a new label - after a not condition
{
 lnum++;
 strcpy(temp,"t");


my_itoa(i_ , si);
strcat(temp, si);

strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , "= not");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;
 printf("%s = not %s\n",temp,st[top]);

my_itoa(lnum, ss);
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "if goto");
strcpy(QIC[ind].arg1, temp);
strcpy(QIC[ind].arg2 , "");
ind++;

 printf("if %s goto L%d\n",temp,lnum);
 i_++;
 label[++ltop]=lnum;
}

void  lab2()  // Create an unconditional label
{
int x;
lnum++;
x=label[ltop--];

my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss , l));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("goto L%d\n",lnum);


my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("L%d: \n",x);
label[++ltop]=lnum;
}

void lab3()   //Add created label
{
int y;
y=label[ltop--];

my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("L%d: \n",y);
}
 
void lab1f()
{
	my_itoa(lnum ,ss );
	strcpy(QIC[ind].result , strcat(ss, l ));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
    	printf("L%d: \n",lnum++);
}

void lab2f()  // if with 2 labels 
{
    strcpy(temp,"t");
    
my_itoa(i_ , si);
strcat(temp, si);

strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , "= not");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;
 printf("%s = not %s\n",temp,st[top]);

my_itoa(lnum, ss);
strcpy(QIC[ind].result , strcat(ss, l));
strcpy(QIC[ind].op , "if goto");
strcpy(QIC[ind].arg1, temp);
strcpy(QIC[ind].arg2 , "");
ind++;

 printf("if %s goto L%d\n",temp,lnum);



    i_++;
    label[++ltop]=lnum;
    lnum++;


	my_itoa(lnum, ss);
	strcpy(QIC[ind].result , strcat( ss,l));
	strcpy(QIC[ind].op , "if goto");
	strcpy(QIC[ind].arg1, temp);
	strcpy(QIC[ind].arg2 , "");
	ind++;
	// printf("if %s goto L%d\n",temp,lnum);

	
	my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l ));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d\n",lnum);
    label[++ltop]=lnum;


	my_itoa(++lnum ,ss );
	strcpy(QIC[ind].result , strcat(ss ,l));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
	printf("L%d: \n",lnum);
 }
void lab3f()
{
    int x;
    x=label[ltop--];

	my_itoa(start ,ss );
strcpy(QIC[ind].result , strcat( ss,l));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d \n",start);


	my_itoa(x ,ss );
	strcpy(QIC[ind].result , strcat(ss,l ));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
    printf("L%d: \n",x);
   
}

void lab4f()
{
    int x;
    x=label[ltop--];


	my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d \n",lnum);   


	my_itoa(x ,ss );
	strcpy(QIC[ind].result , strcat(ss,l));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;

    printf("L%d: \n",x);
}

void my_itoa(int num, char temp1[20])
{
	sprintf(temp1,"%d",num);
	//printf("%s \n",temp1);
	//return temp1;
}



void print_INT_CODE()
{
	int i;
	printf("the value of ind %d\n",ind);
	printf("\n--------------------------------------------------------\n");
	printf("\nINTERMEDIATE CODE\n\n");
	printf("--------------------------------------------------------\n");
	printf("--------------------------------------------------------\n");
	printf("\n%17s%10s%10s%10s%10s","post","op","arg1","arg2","result\n");
	printf("--------------------------------------------------------\n");
	
	for(i=0;i<ind;i++)
	{
		printf("\n%15d%10s%10s%10s%10s", i,QIC[i].op, QIC[i].arg1,QIC[i].arg2,QIC[i].result);
	}
	printf("\n\t\t -----------------------");
	printf("\n");
}

void print_OPT_CODE()
{
	int i;
	printf("the value of ind %d\n",ind);
	printf("\n--------------------------------------------------------\n");
	printf("\nOPTIMIZED INTERMEDIATE CODE\n\n");
	printf("--------------------------------------------------------\n");
	printf("--------------------------------------------------------\n");
	printf("\n%17s%10s%10s%10s%10s","post","op","arg1","arg2","result\n");
	printf("--------------------------------------------------------\n");
	
	for(i=0;i<oind;i++)
	{
		printf("\n%15d%10s%10s%10s%10s", i,OPT[i].op, OPT[i].arg1,OPT[i].arg2,OPT[i].result);
	}
	printf("\n\t\t -----------------------");
	printf("\n");
}

void copy()
{
  oind=ind;
  int i=0;
  for(i=0;i<ind;i++)
  {
	OPT[i] = QIC[i];
  }
}



struct mappping{
	char ext[100];
	char ori[100];
	}map[100];



int isDigit(char t[100])
{
	//printf("inside digit %s\n",t);
	if(t!=NULL)
	{
		int check=atoi(t);
		//printf("value of check %s for %d\n",t,check);
		if(check==0)
			return 1;
		else
			return 0;
	}
	return 1;
}



void copy_prop()
{
	int i=0;
	int k =0;
	int flag=0;
	int temp;
	char temp1[10];
	char ext1[100];
	char ext2[100];
	ind = oind;
	int remove[100] ;
	int cnt = 0;

	for(i=0;i<ind;i++)
	{
		
		char a= OPT[i].op[0];
		
		if(a =='=')
		{
		strcpy(map[k].ext,OPT[i].result);	
		strcpy(map[k].ori,OPT[i].arg1);
		k++;
		}
		
	}
	for(i=0;i<ind;i++)
	{
		char a= OPT[i].op[0];
		

		strcpy(ext1,OPT[i].arg1);
		int check = isDigit(ext1);
		//printf("%s , a is %c Is digit %d \n" ,ext1 , a ,  check);
		int ach = strncmp(ext1, "t" , 1) ; 
		if(check == 1 && a=='=' &&  ach!=0 )
		{	
			remove[cnt] = i;
			cnt++;
		}

		else{
			strcpy(ext1,OPT[i].arg1);	
			strcpy(ext2,OPT[i].arg2);
			for(int j=0;j<k;j++)
			{
			if(strcmp(ext1, map[j].ext)==0)
				strcpy(OPT[i].arg1 , map[j].ori);
			if(strcmp(ext2, map[j].ext)==0)
				strcpy(OPT[i].arg2 , map[j].ori);
			}
	     	   }
	}

	for(int m=0; m<cnt ;m++)
	{	
		printf("%d \n" , remove[m]);		
		for (int x = remove[m]-m ; x <  ind - 1; x++)
		{
			OPT[x] = OPT[x + 1];
			
		}
		oind = oind -1;
	}

}




