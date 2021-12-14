#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "symbolTable.h"
/*

    Assists in running flex file and creating output.

    Created on Feb 6 2017

*/

extern int yylex();
extern int yylineno;
extern int yyleng;
extern char* yytext;
extern FILE *yyin;
extern int yyparse();
extern void yyerror();
extern int lineNumber;
extern int columnNumber;
extern void newline();
extern bool asc;
extern int yyget_debug ( void ); 
FILE* ascFILE;

extern struct symbolTable top_table;

bool asc = false;
bool s = false;
FILE *ascFILE;
FILE *stFILE;


struct symbolTable top_table;

int main(int argc, char *argv[]){
//	yyget_debug();
//	top_table.parent = NULL;
    top_table.num_entries = 0;
    top_table.num_children = 0;
//	yylex();
    addSymbolTableEntry("integer","integer",&top_table,NULL,"primitive");
    addSymbolTableEntry("boolean","boolean",&top_table,NULL,"primitive");
    addSymbolTableEntry("string","string",&top_table,NULL,"primitive");
    addSymbolTableEntry("character","character",&top_table,NULL,"primitive");
    addSymbolTableEntry("real","real",&top_table,NULL,"primitive");

//    addTopChildTable();
	char *file;
	 for (int i =1; i < argc; i++) {

     	if(strcmp(argv[i],"-asc") == 0){
            asc = true;
	 	}else if(strcmp(argv[i],"-st") == 0){

			s = true;

	 	}else {
			file = argv[i];		
		}
	 }
     
	yyin = fopen(file,"r");
	newline();
    int token;
    columnNumber = 0;
    lineNumber = 0;

  	int success = yyparse();
	if(asc){
         char asc_filename[50];
         strcpy(asc_filename,file);
         strcat(asc_filename,".asc");
         ascFILE = fopen(asc_filename,"w+");
     }
	 if (s) {
         char st_filename[50];
         strcpy(st_filename,file);
         strcat(st_filename,".st");
         stFILE = fopen(st_filename,"w+");
		 st(&top_table,stFILE);
		
     	print_symbol_table(&top_table);
	 }
    // printf("\n\nFinal Symbol Table:\n");


    return 0;
}
