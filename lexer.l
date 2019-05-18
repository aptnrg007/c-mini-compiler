%{
	#include<stdio.h>
	#include<string.h>
	#include "y.tab.h"
	int line=1;
	int scope=0;
	int scope_count=0;
%}


DIGIT [0-9]
ALPHA [a-zA-Z]


%%
\/\/.* {printf("comment dected at line no : %d\n",line);} 
\/\*(.*\n)*.*\*\/ {;}
[ \t]  							{;}
[\n]                            {line++; }
int							return INT ;
float							return FLOAT ;
void							return VOID ;
char							return CHAR; 
double						return DOUBLE;
bool							return BOOL;
for							return FOR ;

if							return IF ;
else							return ELSE ;
using							{return USING;}
namespace 					{return NAMESPACE;}
std							{return STD;}


return						{return RETURN;}
public|private|protected 	{ return ACCESS;}
class                     {return CLASS;}

#.* 						{return INCLUDE ;}

{ALPHA}({ALPHA}|{DIGIT})* 			{yylval.id = (char *) strdup(yytext) ; return ID ;}
{DIGIT}+					    {yylval.ival =atoi(yytext);return NUM  ;}
{DIGIT}+"."{DIGIT}+				return FNUM ;
{ALPHA}?\"(\\.|[^\\"])*\"		return STRING ;

"<="							return LE ;
">="							return GE ;
"=="							return EE ;
"!="							return NE ;
">"							    return GT ;
"<"								return LT ;
"="						     	return '=' ;
"{"							    {++scope; return '{' ;}
"}"								{--scope; if(!scope) ++scope_count; return '}' ;}
"("								return '(' ;
")"								return ')' ;
"["								return '[' ;
"]"								return ']' ;
"+"								return '+' ;
"-"								return '-' ;
"*"								return '*' ;
"/"								return '/' ;
"&"								return '&' ;
"&&"							return AND ;
"||"							return OR ;
"!"								return NOT;
"++"							return INCR ;
"--"							return DECR ;
";"								return ';' ;
","							    return ',' ;

.								return yytext[0];

%%


int yywrap (){return 1;}
