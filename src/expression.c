/*
 * =====================================================================================
 *
 *       Filename:  expression.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  04/29/2021 02:18:45 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */
#include <stdlib.h>
#include "expression.h"
#include <stdbool.h>
#include "string.h"

struct expr *create_expr(char *type,char *value,struct expr *left,struct expr *right){
	struct expr *c = malloc(sizeof(struct expr));
	c->type= type;
	c->value= value;
	c->left=left;
	c->right=right;
	c->highest_p=0;
	c->cur_p=0;
	return c;
}
struct expr *set_priority(int p, struct expr *c) {
	c->cur_p =p;
	if (c->right != NULL) {
		c->highest_p = c->right->highest_p;
	}
	return c;
}
struct expr *set_new_highest(struct expr *c) {
	struct expr *nc =  create_expr(c->type,c->value,c->left,c->right);
	int prev_highest= c->right->highest_p + 1;
	nc->cur_p = prev_highest;	
	nc->highest_p = prev_highest;
	free(c);
	return nc;
}

bool typecmp(char *value,struct type_node *head) {
	for (struct type_node *t = head;
		t!=NULL; t=t->next ){
		if (strcmp(t->type,value) == 0) return true;
		if (t->next ==NULL) break;
	}
	return false;
}
struct type_node *add_type(char *type,struct type_node *p){
	struct type_node *c = malloc(sizeof(struct type_node));
	c->next = p;
	c->type = type;
	return c;
}
struct single_operand *create_soper(char *value){
	struct single_operand *c= calloc(1,sizeof(struct single_operand));
	c->value = value;
	return c;
}
struct double_operand *create_doper(char *value,int p){
	struct double_operand *c= calloc(1,sizeof(struct double_operand));
	c->value = value;
	c->p=p;
	return c;
}
void add_right_type(char *type,struct double_operand *c){
	struct type_node *rt = add_type(type,c->right_types);
	c->right_types = rt;
}
void add_return_type(char *type,struct single_operand *c) {
	struct type_node *rt = add_type(type,c->return_types);		
	c->return_types = rt; 
}
void add_double_return_type(char *type,struct double_operand *c) {
	struct type_node *rt = add_type(type,c->return_types);		
	c->return_types = rt; 
}

void add_single_type(char *type,struct single_operand *c){
	struct type_node *t = add_type(type,c->types);
	c->types = t;
}
void add_left_type(char *type,struct double_operand *c){
	struct type_node *lt = add_type(type,c->left_types);
	c->left_types = lt;
}
