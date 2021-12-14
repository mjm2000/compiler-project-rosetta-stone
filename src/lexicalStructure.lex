
%{

/*
    C code can go in this section

    #include "typedefs.h" shown to encapsulate those definitions in separate file
*/

#include <string.h>
#include <stdbool.h>
#include "parser.tab.h"
int lineNumber = 1;
int columnNumber = 1;
int errorCol;
extern bool asc;
extern bool sc;
extern char *file;
extern FILE* ascFILE;

#define ENDCOMMENT 701



void tok() {
    errorCol = columnNumber;
    columnNumber += strlen(yytext);
    if(asc){
        fputs(yytext,ascFILE);
    }
}

void newline() {
    if(asc){
        char line_label[6];
        sprintf(line_label,"%03d: ",yylineno);
        fputs(line_label,ascFILE);
    }
}

void comment() {
    for(int idx=0;idx<strlen(yytext);idx++){
        char character = yytext[idx];
        if(character == '\n'){
            yylineno++;
            columnNumber = 1;
        } else {
            columnNumber += 1;
        }
    }
}

%}
    /* Define FLEX abbreviations - sample provided */
DIGIT		[0-9]

COMMENT_BLOCK     "(*"("("[^*]|[^*]")"|")("|"*"|\r?\n|[^*)]*)*"*)"

STRING            "'"([^']|"\\\\"|"\\n"|"\\t"|"\\"|"\b"|"\\'"|"\""|"\\\"")"'"


%%
    /* Give FLEX rules: "real" is a regex ... and when recognized the lexer will return the constant T_REAL,  */
    /* defined in typedefs.h                                                                                  */
"(*"("("[^*]|[^*]")"|")("|"*"|\r?\n|[^*)]*)*"*)"                    comment(); tok();
\r?\n                                                               tok(); ++yylineno,columnNumber = 1; newline();
[ \t]                                                               tok();
{DIGIT}+\.{DIGIT}+([eE][-+]?{DIGIT}+)?                              yylval.constant_value = (char *) strdup(yytext); tok(); return C_REAL;
{DIGIT}+                                                            yylval.constant_value = (char *) strdup(yytext); tok(); return C_INTEGER;
"integer"                                                           yylval.identifier_value = (char *) strdup(yytext); tok(); return T_INTEGER;
"real"                                                              yylval.identifier_value = (char *) strdup(yytext); tok(); return T_REAL;
"Boolean"                                                           yylval.identifier_value = (char *) strdup(yytext); tok(); return T_BOOLEAN;
"character"                                                         yylval.identifier_value = (char *) strdup(yytext); tok(); return T_CHARACTER;
"'"([^']|"\\\\"|"\\n"|"\\t"|"\\"|"\b"|"\\'"|"\""|"\\\"")"'"         yylval.constant_value = (char *) strdup(yytext);tok(); return C_CHARACTER;
"string"                                                            yylval.identifier_value = (char *) strdup(yytext); tok(); return T_STRING;
\"([^"\n]|"\\n"|"\\\"")*\"                                          yylval.constant_value = (char *) strdup(yytext);tok(); return C_STRING;
"true"                                                              yylval.constant_value = (char *) strdup(yytext);tok(); return C_TRUE;
"false"                                                             yylval.constant_value = (char *) strdup(yytext);tok(); return C_FALSE;
"null"                                                              yylval.constant_value = (char *) strdup(yytext);tok(); return NULL_PTR;
"reserve"                                                           tok(); return RESERVE;
"release"                                                           tok(); return RELEASE;
"for"                                                               tok(); return FOR;
"while"                                                             tok(); return WHILE;
"if"                                                                tok(); return IF;
"then"                                                              tok(); return THEN;
"else"                                                              tok(); return ELSE;
"switch"                                                            tok(); return SWITCH;
"case"                                                              tok(); return CASE;
"otherwise"                                                         tok(); return OTHERWISE;
"type"                                                              tok(); return TYPE;
"function"                                                          tok(); return FUNCTION;
"("                                                                tok(); return L_PARENTHESIS; // error
")"                                                                 tok(); return R_PARENTHESIS;
"["                                                                 tok(); return L_BRACKET;
"]"                                                                 tok(); return R_BRACKET;
"{"                                                                 tok(); return L_BRACE;
"}"                                                                 tok(); return R_BRACE;
"'"                                                                 tok(); return S_QUOTE;
"\""                                                                tok(); return D_QUOTE;
";"                                                                 tok(); return SEMI_COLON;
":"                                                                 tok(); return COLON;
","                                                                 tok(); return COMMA;
"->"                                                                tok(); return ARROW;
"\\"                                                                tok(); return BACKSLASH;
"+"                                                                 tok(); return ADD;
"-"                                                                 tok(); return SUB_OR_NEG;
"*"                                                                 tok(); return MUL;
"/"                                                                 tok(); return DIV;
"%"                                                                 tok(); return REM;
"\."                                                                tok(); return DOT;
"<"                                                                 tok(); return LESS_THAN;
"="                                                                 tok(); return EQUAL_TO;
":="                                                                tok(); return ASSIGN;
"i2r"                                                               tok(); return INT2REAL;
"r2i"                                                               tok(); return REAL2INT;
"isNull"                                                            tok(); return IS_NULL;
"!"                                                                 tok(); return NOT;
"&"                                                                 tok(); return AND;
"|"                                                                 tok(); return OR;
[a-zA-Z0-9_]+                                                       yylval.identifier_value = (char *) strdup(yytext); tok(); return ID;
%%

int yywrap(void){
    return 1;
}
