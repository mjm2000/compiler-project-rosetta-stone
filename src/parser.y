%{
// C Declarations
// #include "typedefs.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include "symbolTable.h"
//#include "expression.h"

#define YYDEBUG 1

int yylex(void);

extern int yylineno;

void yyerror (char const *s) {
  extern int errorCol;
  extern int lineNumber;
  extern char* yytext;
  extern int yylineno;
   fprintf (stderr, "(%s) token:\"%s\", Line: %d, Col: %d\n", s,yytext,yylineno,errorCol);
 }

extern struct symbolTable top_table;

struct symbolTable* current_table = &top_table;

extern void addSymbolTableEntry();
extern bool checkIfEntryExists();
extern struct symbolTableEntry *getEntryById();
extern struct symbolTableEntry *getTail();
extern struct expr  *create_expr();
extern void add_single_type();
extern void add_return_type();
extern bool typecmp();
extern struct single_operand *create_soper();
extern struct double_operand *create_doper();

void addChildTable(){
  struct symbolTable* new_table = (struct symbolTable *) malloc(sizeof(struct symbolTable));
  new_table->parent = current_table;
  new_table->num_children = 0;
  new_table->num_entries = 0;
  current_table->children[current_table->num_children] = new_table;
  current_table->num_children += 1;
  current_table = new_table;
}

void addNewChildren(struct symbolTableEntry* parent_entry){
  struct symbolTableEntry* child = parent_entry->child_entry;
  if(current_table->num_children == 0){
    current_table->next_entry = child;
    current_table->num_entries += parent_entry->num_children;
  } else {
    struct symbolTableEntry* tail_entry = getTail(current_table->next_entry);
    tail_entry->next_entry = child;
    current_table->num_entries += parent_entry->num_children;
  }
}

char* incoming_type;
char* incoming_value;
char* incoming_struct_id;
char* incoming_arrow_id;
bool in_function = false;
bool in_struct = false;
bool in_arrow = false;
struct symbolTableEntry* function_type_entry;
int empty_p_list = 0;
int arg_count = 0;



struct identifier_ls{
	char *identifier; 
	struct identifier_ls *next; 
	struct expr *assignment;
};
struct declaration{
	struct identifier_ls *iden_list;
	char *type;
};
struct declaration_ls {
	struct declaration *dec; 
	struct declaration_ls *next;
};

struct argument_ls {
	struct expr *arg;
	struct argument_ls *next; 
};

struct simple_stmt{
	char *iden;
	struct expr *assignment; 
};


struct compound_stmt{
	struct stmt **stmts;
	int s_amount;
	struct expr	**exprs;  
	int e_amount;
	struct stmt_ls *sblock;
};

struct stmt{
	char* type;
	union {
		struct compound_stmt *c_stmt;
		struct simple_stmt *s_stmt;
	};
};



struct stmt_ls{
	struct stmt *value;  
	struct stmt_ls *next;
};
struct stmt *create_cstmt(char *type,struct stmt *stmts[],int s_amount, struct expr *exprs[],int e_amount,struct stmt_ls *sblock) {
	struct compound_stmt *value = calloc(1,sizeof(struct compound_stmt));
	value->stmts = malloc(sizeof(struct stmt) * s_amount);
	for (int i = 0; i < s_amount; i++ ){
		value->stmts[i] = stmts[i]; 
	}
	value->exprs = malloc(sizeof(struct expr) * e_amount);
	for (int i = 0; i < e_amount; i++ ){
		value->stmts[i] = stmts[i]; 
	}
	value->sblock = sblock; 
	struct stmt *c = calloc(1,sizeof(struct stmt));
	c->type = type;
	c->c_stmt = value;
	return c; 
}

struct stmt *create_sstmt(char *iden, struct expr *value) {
	struct simple_stmt  *sstmt  = malloc(sizeof(struct simple_stmt));
	sstmt->iden = iden;
	sstmt->assignment = value;

	struct stmt *c = calloc(1,sizeof(struct stmt));

	c->type = "assign";
	c->s_stmt = sstmt;
	
	return c;  
}
struct stmt_ls *append_stmt_ls(struct stmt *cur,struct stmt_ls *prev){
	struct stmt_ls *c = malloc(sizeof(struct stmt_ls));
	c->next = prev;
	c->value = cur; 	
	return c;
}
struct argument_ls *append_arg_ls(struct expr *arg, struct argument_ls *prev){
	struct argument_ls *c = calloc(1,sizeof(struct argument_ls));
	c->next = prev;
	c->arg = arg;	
	return c;		
}

struct identifier_ls *append_iden_ls(char *iden, struct expr *assign,struct identifier_ls *prev){
	struct identifier_ls *c = calloc(1,sizeof(struct identifier_ls));
	c->identifier = iden;
	c->next = prev;
	c->assignment = assign;	
	return c; 
}
struct declaration *create_decl(char *type, struct identifier_ls *iden_ls){
	//add type checking
	struct declaration *c = malloc(sizeof(struct declaration));
	c->type = type;
	c->iden_list = iden_ls;
	return c;
}

struct declaration_ls *append_decl_ls(struct declaration *cur,struct declaration_ls *prev){
	struct declaration_ls *c = malloc(sizeof(struct declaration_ls));
	c->next = prev;
	c->dec = cur; 	
	return c;
}

void dblock_to_symbol_table(char *parent_id, struct declaration_ls *ls) {
	for (struct declaration_ls *d = ls; d != NULL; d=d->next){
		struct declaration *dec = d->dec;
		for (struct identifier_ls *i= dec->iden_list; i != NULL;i=i->next ) {
			// add type checking

	//	printf("type:%s, iden:%s \n",dec->type,i->identifier);
			addSymbolTableEntry(i->identifier, dec->type,current_table,parent_id,i->assignment->value);
			if (i->next == NULL) break;	
//			free(i);
		}	
		if (d->next == NULL) break;	
	}	
}




bool isnumber(char *value){
	for (int i = 0; value[i] != '\0'; i++) {
		if (!(value[i] >= '0' && value[0] <= '9' ) || value[i]=='.') 
			return false; 
	}
	return true;
}
bool isoperator(char *op){
	char *ops = "+-*/%" ;
	for (int i = 0; i < 4; i++ ) {
		if (op[0] == ops[i]) return true;
	}
	return false;
}




struct reg_ls *reg_list = NULL;

int get_reg_node(char *iden){
	return 1;
}

bool is_leaf(struct expr *c){
	return c != NULL && c->left == NULL && c->right == NULL;
}

bool isboolean(char *c){
	return strcmp(c,"true") == 0 || strcmp(c,"false") == 0;
}

struct reg_ls{
	int reg_id; 
	char *op;
	struct reg_ls *next;
};

struct reg_ls *temp_var_stack = NULL;

void t_push(){
	struct reg_ls *c = malloc(sizeof(struct reg_ls));
	c->next = temp_var_stack; 	
	if (temp_var_stack != NULL) {
		c->reg_id = temp_var_stack->reg_id + 1;
	}else{
		c->reg_id = 0;
	}
	temp_var_stack = c;
}
void push_op(char *op){
	if (temp_var_stack != NULL) {
		
		temp_var_stack->op = op; 
	}
}
struct reg_ls *pop(){
	struct reg_ls *c = temp_var_stack;
	temp_var_stack = c->next;
	return c ; 
}
void reverse(){
	struct reg_ls *c  = temp_var_stack;
	struct reg_ls *prev  = NULL;
	struct reg_ls *next  = NULL;
	while (c != NULL){
		next = c->next;
		c->next = prev;
		
		prev = c;
		c = next;
	}
	temp_var_stack = prev;
}
void print_reg_ls(char *buffer){
	reverse();
	struct reg_ls *c = temp_var_stack;	
	while (c->next != NULL && c->op != NULL ){
		sprintf(buffer,"%st%i = t%i %s t%i\n",
			buffer,
			c->next->reg_id,
			c->next->reg_id,
			c->op,
			c->reg_id	
		);	
//		struct reg_ls *prev = c;	
		c= c->next;	
//		free(prev);
	}
}

void print_arguments(struct expr *c,char *buffer){
	struct expr *arg =  c->right;
	int a = 1; 
	while ( c != NULL && arg != 1 ){
		if( arg->left != NULL){
			sprintf(buffer,"%sa%i = %s\n",buffer,a,arg->left->value);	
		}
		a += 1;
		arg = arg->right;
	}
	sprintf(buffer,"%sjmp %s\n",buffer,c->value);
}


void print_tree(struct expr *c,char *buffer){
	if (c != NULL && strcmp(c->type,"function call") == 0) {
			if ( temp_var_stack == NULL) t_push();
			
			print_arguments(c,buffer);
			return; 
	}else if (c->right != NULL && c->left != NULL ){
			
		print_tree(c->right,buffer);
		char reg[100];
		if ( strcmp(c->type,"function call") == 0) {
			if ( temp_var_stack == NULL) t_push();
			
			print_arguments(c,buffer);
			return; 
		} else{
			if (is_leaf(c->right) && is_leaf(c->left) ) {
				t_push();	
				sprintf(reg, "t%i" ,temp_var_stack->reg_id);
				sprintf(buffer,"%s%s = %s %s %s\n",buffer,reg,c->left->value,c->value,c->right->value);
			}else if (is_leaf(c->right)) {
				if (temp_var_stack==NULL) t_push();
				sprintf(reg, "t%i" ,temp_var_stack->reg_id);
				sprintf(buffer,"%s%s = %s %s %s\n",buffer,reg,reg,c->value,c->right->value);
			}else if (is_leaf(c->left)) {
				sprintf(reg, "t%i" ,temp_var_stack->reg_id);
				sprintf(buffer,"%s%s = %s %s %s\n",buffer,reg,reg,c->value,c->left->value);
			}else {
				push_op(c->value);
			}
		}
			print_tree(c->left,buffer);
	}
}

char *statement_list_code(struct stmt_ls *ls){
	if(ls==NULL) return "error";
	struct stmt_ls *cur = ls; 	
	char *buffer = malloc(sizeof(char)* 100000);
	while (cur != NULL ){
		struct stmt *cur_stmt = cur->value;
		char *type  = cur_stmt->type;
		if (strcmp(type,"for") == 0) {
			
		}
		else if ( strcmp(type,"if") == 0) {

		}
		else if ( strcmp(type,"while") == 0) {

		}
		else if ( strcmp(type,"switch") ==  0) {
		
		}
		else if ( strcmp(type,"assign") == 0) {
			struct simple_stmt *ss = cur_stmt->s_stmt;
			if (is_leaf(ss->assignment) ){  
				t_push();
				sprintf(buffer,"%st%i = %s\n",buffer,
					temp_var_stack->reg_id,
					ss->assignment->value
				);
			}else{
				print_tree(ss->assignment,buffer);
			}	
			int reg = temp_var_stack->reg_id;
			print_reg_ls(buffer);
			sprintf(buffer,"%s%s = t%i\n",buffer,ss->iden,reg);
		}
		if (cur->next == NULL) break;
		cur = cur->next; 

	}
	return buffer;
} 
struct p_decl{
	char *id;
	char *type;	
};

struct p_list {
	struct p_decl *value;
	struct p_list *next;
};

struct p_decl *create_pdecl(char *id,char *type){
	struct p_decl *c = malloc(sizeof(struct p_decl));
	c->id = id;
	c->type = type;
	return c;
}
struct p_list *append_plist(struct p_decl *value,struct p_list *ls){
	struct p_list *c = malloc(sizeof(struct p_list));
	c->value=value;  
	c->next=ls;
	return c;
}
void params_to_functions(char *function_name,struct p_list *ls){
	struct p_list *cl = ls; 
	while (cl != NULL){
		struct p_decl *c = cl->value;
		addSymbolTableEntry(c->id,c->type,current_table,function_name,c->type);	
		cl = cl->next;
	}
}

struct assignable{
	char *iden;
	struct argument_ls *arg_ls;
	bool is_function_call;
};

struct  assignable *create_assignable(char *iden,struct argument_ls *arg_ls, bool is_function_call){
	struct assignable  *c = malloc(sizeof(struct assignable));
	c->iden = iden ;
	c->arg_ls = arg_ls ;
	c->is_function_call = is_function_call;
}
struct expr *assignable_to_expr(struct assignable *ca){
	if ( ca->is_function_call)	{
		struct argument_ls *cn = ca->arg_ls;  
		struct expr *prev;
		while (cn != NULL ){
			prev = create_expr("arg","arg",cn->arg,prev);	
			cn = cn->next; 
		}
		return create_expr("function call",ca->iden,NULL,prev);	
			
	}else{
		struct symbolTableEntry *e= getEntryById(ca->iden,current_table);
		return create_expr(e->value->type, ca->iden ,NULL,NULL);
	}
}

%}
%define parse.lac full
%define parse.error verbose

%union {
  char *typename_value;
  char *identifier_value;
  char *iden;
  char *constant_value;
  struct expr *expression_value;
  char *declaration_string;
  char *function_type_string;
  struct single_operand *single_op;
  struct double_operand *double_op;
  struct identifier_ls *identifier_ls;
  struct declaration *declaration; 
  struct declaration_ls *declaration_ls;
  struct argument_ls *argument_ls;
  struct stmt *statement;
  struct stmt_ls *statement_ls;
  struct p_list *param_ls;
  struct p_decl *param;
  struct assignable *assign;
}


%token TYPE  RESERVE RELEASE FOR WHILE IF THEN ELSE SWITCH CASE OTHERWISE  FUNCTION L_PARENTHESIS R_PARENTHESIS L_BRACKET R_BRACKET L_BRACE R_BRACE S_QUOTE D_QUOTE SEMI_COLON COLON COMMA ARROW BACKSLASH  REM DOT LESS_THAN EQUAL_TO ASSIGN INT2REAL REAL2INT IS_NULL NOT AND OR ADD SUB_OR_NEG MUL DIV


%token <constant_value>  C_INTEGER C_REAL C_CHARACTER C_STRING C_TRUE C_FALSE NULL_PTR

%token <identifier_value> ID T_INTEGER T_BOOLEAN T_CHARACTER T_STRING T_REAL 

%type <identifier_value> typename identifier  type_identifier  struct_keyword arrow_keyword func_keyword

%type <assign> assignable

%type  <param> parameter_declaration
%type <param_ls> pblock parameter_list non_empty_parameter_list 

%type <expression_value> expression constant optional_assignment

%type <identifier_ls> identifier_list  

%type <declaration> declaration;

%type <declaration_ls> declaration_list dblock optional_dblock

%type <argument_ls> ablock argument_list non_empty_argument_list 

%type <statement> statement simple_statement compound_statement

%type <statement_ls> statement_list sblock

%type <single_op>  preUnaryOperator postUnaryOperator

%type <double_op>  binaryOperator


%left ADD SUB_OR_NEG
%left MUL DIV

%start program

%%

program:                definition_list sblock{ 
	   							
	   						char *code = statement_list_code($2);	
							printf("%s",code);
						};

definition_list:        %empty
                        | definition definition_list{};

definition:             struct_keyword dblock {	
		  					addSymbolTableEntry($1,"struct",current_table,NULL,NULL);
		  					dblock_to_symbol_table($1,$2); 
						}
                        | TYPE identifier COLON C_INTEGER ARROW identifier {
							char temp_list_typename[100] = {};
							snprintf(temp_list_typename,99,"%s (%s)",$6,$4); 
							char* list_typename = (char*) malloc(sizeof(char)*strlen(temp_list_typename)); 
							strcpy(list_typename,temp_list_typename); 
							addSymbolTableEntry($2,list_typename,current_table,NULL,"list");
						}
                        | arrow_keyword pblock ARROW identifier {
							
					//		printf("string:%s\n",$1);

							addSymbolTableEntry($1,$4,current_table,NULL,"function");
						//	addTopChildTable();
							params_to_functions($1,$2);
							
						//	print_symbol_table(current_table);
						//	current_table = current_table->parent;
								
						}
                        | func_keyword sblock {
							char *code = statement_list_code($2);	

							printf("%s:\n%sendfunc\n",$1,code);
							//free(code);
							in_function = false;
						};

struct_keyword:         TYPE identifier COLON {
			  				$$ = $2;
						} 
arrow_keyword:          TYPE identifier COLON {
							incoming_arrow_id = $2;
							in_arrow = true; 
							$$=$2;
						};

func_keyword:           FUNCTION identifier COLON identifier {
					//		if(!checkIfEntryExists($4,current_table)){
					//			yyerror("ERROR: Identifier not defined yet");
					//		} 
							addSymbolTableEntry($2,$4,current_table,NULL,"function definition");
							function_type_entry = getEntryById($4,current_table); 
							in_function = true;
							$$=$2;
						};

sblock:                 open_brace optional_dblock statement_list R_BRACE {
	  						current_table = current_table->parent;
							$$ = $3;
						}

open_brace:             L_BRACE {
		  					addChildTable();
		  					if (in_function) addNewChildren(function_type_entry); 
						}

optional_dblock:        %empty{}
                        | dblock{dblock_to_symbol_table(NULL,$1);}

dblock:                 L_BRACKET declaration_list R_BRACKET{$$=$2;}

declaration_list:       declaration SEMI_COLON declaration_list {
							 
							$$ = append_decl_ls($1,$3);
						}
						| declaration{
							$$ = append_decl_ls($1,NULL);	
						};

declaration:            type_identifier COLON identifier_list {
		   					$$ = create_decl($1,$3);
						}

// Add symbol table entries for declarations in this rule
identifier_list:        identifier optional_assignment COMMA identifier_list {
			   				$$ =  append_iden_ls($1,$2,$4);
						} 
						| identifier optional_assignment {
						//	printf("%s:iden \n", $1);
							$$ = append_iden_ls($1,$2,NULL); 
						}


optional_assignment:    %empty {$$=create_expr("","",NULL,NULL);}
                        | ASSIGN constant{$$=$2;}

type_identifier:        identifier {$$ = $1;};

identifier:             typename{ $$ = $1; } | ID ;

typename:               T_BOOLEAN | T_CHARACTER| T_STRING | T_INTEGER | T_REAL;

statement_list:         compound_statement statement_list {
			  				
			  				$$ = append_stmt_ls($1,$2);
						}
                        | compound_statement{
							$$ = append_stmt_ls($1,NULL);
						}
                        | simple_statement SEMI_COLON statement_list{
							
							$$ = append_stmt_ls($1,$3);
						}
                        | simple_statement SEMI_COLON{
							$$ = append_stmt_ls($1,NULL);
						}

statement:              compound_statement{$$=$1;} | simple_statement {$$=$1;}

compound_statement:     FOR L_PARENTHESIS statement SEMI_COLON expression SEMI_COLON statement R_PARENTHESIS sblock
                        | WHILE L_PARENTHESIS expression R_PARENTHESIS sblock
                        | IF L_PARENTHESIS expression R_PARENTHESIS THEN sblock ELSE sblock {
						//	struct expr[] = {}
						//	$$ = create_cstmt(); 	
						//	addChildTable();
								
						}
                        | SWITCH L_PARENTHESIS expression R_PARENTHESIS CASE constant COLON sblock optional_case OTHERWISE COLON sblock{
							
						}
                        | sblock;

optional_case:          %empty
                        | CASE constant COLON sblock optional_case;

simple_statement:       assignable ASSIGN expression{
							addSymbolTableEntryExp($1->iden,current_table,NULL,$3); 
							$$ = create_sstmt($1->iden,$3);
						}

assignable:             identifier {
								$$ = create_assignable($1,NULL,false);
						}
                        | assignable ablock {
							// todo expr
							if (!checkIfEntryExists($1->iden,current_table)) yyerror("implicit call of function");
							else {
								struct symbolTableEntry  *t= getEntryById($1->iden,current_table);
							
								$$ = create_assignable($1->iden,$2,true);
							}
						}
                        | assignable recOp ID

constant:               C_TRUE{$$=create_expr("Boolean",$1,NULL,NULL);} 
						| C_FALSE {$$=create_expr("Boolean",$1,NULL,NULL);}
						| C_CHARACTER {$$=create_expr("char",$1,NULL,NULL);}
						| C_STRING {$$=create_expr("string",$1,NULL,NULL);}
						| C_INTEGER {$$=create_expr("integer",$1,NULL,NULL);} 
						| C_REAL{$$=create_expr("real",$1,NULL,NULL);}

expression:             constant { $$ = $1;}
                        | preUnaryOperator expression {
								
							if(typecmp($2->type,$1->types)) {
								
								
								$$ = create_expr($1->value,$1->return_types->type,$2,NULL);
							}	
							else {
								yyerror("type mismatch\n");
							}
						}
                        | expression postUnaryOperator  {
						//	if(typecmp($1->type,$2->types)) {
								$$ = create_expr($2->value,$2->return_types->type,$1,NULL);	
						//	}	
					//		else {
								yyerror("type mismatch\n");
					//		}
						}
                        | assignable {
				//			struct symbolTableEntry *cur = getEntryById($1,current_table);
				//			if (cur != NULL) {
								$$ = assignable_to_expr($1); 
				//			}else{
						//		yyerror("identifier not defined");
				//			}
						}
						| L_PARENTHESIS expression R_PARENTHESIS {
							$$ = set_new_highest($2);
						}
                        | expression binaryOperator expression {
							// $t1 = $t2 + 5
							if (typecmp($1->type, $2->right_types) 
							 && typecmp($1->type, $2->left_types)){
								struct expr *c=create_expr($2->return_types->type,$2->value,$1,$3);
								$$ = c;	
							}
						}
                        
                        | memOp assignable;
				

pblock:                 L_PARENTHESIS parameter_list R_PARENTHESIS{$$=$2;}

parameter_list:         %empty{append_plist(NULL,NULL);}
                        | non_empty_parameter_list{$$=$1;};

non_empty_parameter_list: parameter_declaration COMMA non_empty_parameter_list{
							$$ = append_plist($1,$3);		
						} 
					    | parameter_declaration{
							$$ = append_plist($1,NULL);
						}

parameter_declaration:  identifier COLON identifier {
							$$ = create_pdecl($3,$1);	
						};


ablock:                 L_PARENTHESIS argument_list R_PARENTHESIS{$$=$2;};

argument_list:          %empty { $$=append_arg_ls(NULL,NULL); }
                        | non_empty_argument_list{$$=$1;} 

non_empty_argument_list: expression COMMA non_empty_argument_list {
					   		$$ = append_arg_ls($1,$3); 
						} 
						| expression {
							$$ = append_arg_ls($1,NULL);
						}

preUnaryOperator:       SUB_OR_NEG{
							struct single_operand *c= create_soper("neg");							
							add_single_type("real",c);
							add_single_type("integer",c);
							$$ = c;
						 } 
				        | ADD {
							struct single_operand *c= create_soper("pos");							
							add_single_type("real",c);
							add_single_type("integer",c);

						//	add_return_type("real",c);
							add_return_type("int",c);
							$$ = c;
						 } 						
						| NOT {
							struct single_operand *c= create_soper("not");							
							add_single_type("Boolean",c);
							add_return_type("Boolean",c);
							$$ =c;
						 } 
						| INT2REAL {
							struct single_operand *c= create_soper("int2real");							
							add_single_type("integer",c);
							add_return_type("Boolean",c);
							$$ =c;
						 } 
						| REAL2INT{
							struct single_operand *c= create_soper("real2int");							
							add_single_type("real",c);
							add_return_type("Boolean",c);
							$$ = c;
						}

postUnaryOperator:      IS_NULL;

memOp:                  RESERVE | RELEASE;

recOp:                  DOT;

binaryOperator:         ADD{
			  				struct double_operand *c=create_doper("+",1);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("integer",c);
							$$ = c;
						} 
			  			| SUB_OR_NEG {
							struct double_operand *c=create_doper("-",1);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("integer",c);
							$$ = c;
} 
						| MUL { 
							struct double_operand *c = create_doper("*",2);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("integer",c);
							$$ = c;
						}
						| DIV { 
							struct double_operand *c = create_doper("/",2);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("integer",c);
							$$ = c;
						}
                        | REM { 
							struct double_operand *c = create_doper("rem",2);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("integer",c);
							$$ = c;
						}
                        | AND {	
							struct double_operand *c = create_doper("&&",1);
							add_right_type("Boolean",c);
							add_left_type("Boolean",c);	
							add_double_return_type("integer",c);
							$$ = c;
						} 
						| OR {	
							struct double_operand *c = create_doper("||",1);
							add_right_type("Boolean",c);
							add_left_type("Boolean",c);	
							add_double_return_type("integer",c);
							$$ = c;
						}
                        | LESS_THAN  {	
							struct double_operand *c = create_doper("<",1);
							add_right_type("integer",c);
							add_left_type("integer",c);	
							add_double_return_type("boolean",c);
							$$ = c;
						}
						| EQUAL_TO {
							struct double_operand *c = create_doper("==",1);
							add_right_type("Boolean",c);
							add_left_type("Boolean",c);	
							add_double_return_type("integer",c);
							$$ = c;
						}



