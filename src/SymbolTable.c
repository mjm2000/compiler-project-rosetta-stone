/*
 * =====================================================================================
 *
 *       Filename:  SymbolTable.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  04/29/2021 03:19:12 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "symbolTable.h"


int table_counter = 0;

extern struct symbolTable top_table;

extern struct expr *create_expr();
extern void yyerror(char *value);

void print_node(FILE *file, struct symbolTable *head, int scope){
	if (head == NULL) return;
	if (scope >= -1) {
		for (struct symbolTableEntry *elem = head->next_entry;
			elem->next_entry != NULL; elem = elem->next_entry) {
			if (!strcmp("return type",elem->name)
			 || !strcmp("primitive",elem->value->type)) continue;
			fprintf(file,"%s: %i: %s: ",elem->name,scope,elem->value->type );	
			if ( strcmp("string",elem->value->type) == 0
				|| strcmp("integer",elem->value->type)  == 0
    	        || strcmp("boolean", elem->value->type) == 0
    	        || strcmp("string", elem->value->type) == 0
    	        || strcmp("character", elem->value->type)  == 0
				|| strcmp("real", elem->value->type) == 0
				
			){ 
				fprintf(file,"local(%s)\n",elem->value->value);
			} 
			
			else {
				fprintf(file,"%s\n",elem->value->type);
			}
			
		}	

	}	
	for (int i = 0; i < head->num_children; i++){
		scope+=1;
		print_node(file,head->children[i],scope);
	}
}
void st(struct symbolTable *head,FILE *file){
	fprintf(file,"NAME : SCOPE : TYPE : Extra annotation\n");	
	print_node(file,head,0);
}

void addTopChildTable(){
  struct symbolTable* new_table = (struct symbolTable *) malloc(sizeof(struct symbolTable));
  new_table->parent = &top_table;
  new_table->num_children = 0;
  new_table->num_entries = 0;
  top_table.children[top_table.num_children] = new_table;
  top_table.num_children += 1;
  top_table = *new_table;
}

struct symbolTableEntry* getTail(struct symbolTableEntry* top_entry){
    if(top_entry->next_entry == NULL){
        return top_entry;
    }
    struct symbolTableEntry* current_entry;
    current_entry = top_entry->next_entry;
    while(current_entry->next_entry != NULL){
        current_entry = current_entry->next_entry;
    }
    return current_entry;
}

void print_symbol_table(struct symbolTable* table){
    struct symbolTableEntry *current_entry = table->next_entry;
    printf("Symbol Table %d: %d Children | %d Entries\n",table_counter,table->num_children,table->num_entries);
    while(current_entry != NULL){
        printf("-   %s has value: %s   %s\n",current_entry->name,current_entry->value->type,current_entry->value->value);
        struct symbolTableEntry* child = current_entry->child_entry;
        while(child != NULL){
            printf("-    -   %s has value %s   %s\n",child->name,child->value->type,child->value->value);
            child = child->next_entry;
        }
        current_entry = current_entry->next_entry;
    }
    for(int i=0; i<table->num_children; i++){
        table_counter += 1;
        print_symbol_table(table->children[i]);
    }
}

bool checkIfEntryExists(char *id, struct symbolTable* table){
    bool in_current_table = false;
    struct symbolTableEntry* current_entry = table->next_entry;
    while(current_entry != NULL){
        char *id_to_check = current_entry->name;
        int is_id = strcmp(id,id_to_check);
        if(is_id == 0){
            in_current_table = true;
        }
        current_entry = current_entry->next_entry;
    }
    if(table->parent != NULL){
        in_current_table = checkIfEntryExists(id,table->parent) || in_current_table;
    }
    return in_current_table;
}

struct symbolTableEntry* getEntryById(char* id, struct symbolTable* table){
    struct symbolTableEntry* current_entry = table->next_entry;
    while(current_entry != NULL){
        char *id_to_check = current_entry->name;
        int is_id = strcmp(id,id_to_check);
        if(is_id == 0){
            return current_entry;
        }
        current_entry = current_entry->next_entry;
    }
    if(table->parent != NULL){
         return getEntryById(id,table->parent);
    }
    return NULL;
}

void addSymbolTableEntry(char *id,char *type, struct symbolTable* table, char* parent_id, char* anno){
    bool already_declared = checkIfEntryExists(id,table);
   // if(already_declared){
   //     yyerror("ERROR: Identifier already declared.");
   // }

    struct symbolTableEntry *new_entry;
    new_entry = malloc(sizeof(struct symbolTableEntry));
    new_entry->isComplex = 0;
    new_entry->num_children = 0;
    new_entry->name = id;
	new_entry->value = create_expr(type,anno,NULL,NULL); 
//    new_entry->value->type = type;
    new_entry->next_entry = NULL;
    new_entry->value->value = anno;

    if(parent_id != NULL){
        struct symbolTableEntry* parent_entry = getEntryById(parent_id,table);
        if(parent_entry->num_children == 0){
            parent_entry->child_entry = new_entry;
            parent_entry->num_children += 1;
        } else {
            struct symbolTableEntry* tail_entry = getTail(parent_entry->child_entry);
            tail_entry->next_entry = new_entry;
            parent_entry->num_children += 1;
        }
    } else if(table->num_entries == 0){
        table->next_entry = new_entry;
        table->num_entries += 1;
    } else {
        struct symbolTableEntry* tail_entry = getTail(table->next_entry);
        tail_entry->next_entry = new_entry;
        table->num_entries += 1;
    }
}
void addSymbolTableEntryExp(char *id, struct symbolTable* table, char* parent_id, struct expr *value){
    bool already_declared = checkIfEntryExists(id,table);
   // if(already_declared){
   //     yyerror("ERROR: Identifier already declared.");
   // }

    struct symbolTableEntry *new_entry;
    new_entry = malloc(sizeof(struct symbolTableEntry));
    new_entry->isComplex = 0;
    new_entry->num_children = 0;
    new_entry->name = id;
	new_entry->value = value; 
//    new_entry->value->type = type;

    if(parent_id != NULL){
        struct symbolTableEntry* parent_entry = getEntryById(parent_id,table);
        if(parent_entry->num_children == 0){
            parent_entry->child_entry = new_entry;
            parent_entry->num_children += 1;
        } else {
            struct symbolTableEntry* tail_entry = getTail(parent_entry->child_entry);
            tail_entry->next_entry = new_entry;
            parent_entry->num_children += 1;
        }
    } else if(table->num_entries == 0){
        table->next_entry = new_entry;
        table->num_entries += 1;
    } else {
        struct symbolTableEntry* tail_entry = getTail(table->next_entry);
        tail_entry->next_entry = new_entry;
        table->num_entries += 1;
    }
}
