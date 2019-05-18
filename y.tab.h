/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INT = 258,
    FLOAT = 259,
    CHAR = 260,
    VOID = 261,
    DOUBLE = 262,
    BOOL = 263,
    FOR = 264,
    IF = 265,
    ELSE = 266,
    CLASS = 267,
    ACCESS = 268,
    USING = 269,
    NAMESPACE = 270,
    STD = 271,
    ID = 272,
    NUM = 273,
    STRING = 274,
    FNUM = 275,
    INCLUDE = 276,
    RETURN = 277,
    GE = 278,
    EE = 279,
    LE = 280,
    NE = 281,
    LT = 282,
    GT = 283,
    AND = 284,
    OR = 285,
    NOT = 286,
    INCR = 287,
    DECR = 288
  };
#endif
/* Tokens.  */
#define INT 258
#define FLOAT 259
#define CHAR 260
#define VOID 261
#define DOUBLE 262
#define BOOL 263
#define FOR 264
#define IF 265
#define ELSE 266
#define CLASS 267
#define ACCESS 268
#define USING 269
#define NAMESPACE 270
#define STD 271
#define ID 272
#define NUM 273
#define STRING 274
#define FNUM 275
#define INCLUDE 276
#define RETURN 277
#define GE 278
#define EE 279
#define LE 280
#define NE 281
#define LT 282
#define GT 283
#define AND 284
#define OR 285
#define NOT 286
#define INCR 287
#define DECR 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 63 "icg2.y" /* yacc.c:1909  */
int ival ; char *id; float fval;

#line 123 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
