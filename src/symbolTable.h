#include <stdio.h>
#include "expression.h"


struct symbolTableEntry {
    char* name;
   	struct expr *value; 
    int num_children;
    int isComplex;
    struct complexType* complex_type;
    struct symbolTableEntry* child_entry;
    struct symbolTableEntry* next_entry;
};

struct symbolTable {
    int num_entries;
    int num_children;
    struct symbolTableEntry* next_entry;
    struct symbolTable* parent;
    struct symbolTable* children[10];
};


void print_symbol_table(struct symbolTable* table);

void print_node(FILE *file, struct symbolTable *head, int scope);
void st(struct symbolTable *head,FILE *file);

void addTopChildTable();


struct symbolTableEntry* getTail(struct symbolTableEntry* top_entry);


void print_symbol_table(struct symbolTable* table);
bool checkIfEntryExists(char *id, struct symbolTable* table);


struct symbolTableEntry* getEntryById(char* id, struct symbolTable* table);
void addSymbolTableEntry(char *id,char *type, struct symbolTable* table, char* parent_id, char* anno);
void addSymbolTableEntryExp(char *id, struct symbolTable* table, char* parent_id, struct expr *value);
