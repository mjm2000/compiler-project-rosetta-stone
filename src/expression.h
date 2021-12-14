#include <stdbool.h>
struct expr {
	char *type; 
	char *value;
	struct expr *right;
	struct expr *left;
	int highest_p;
	int cur_p;
};
struct type_node{
	char *type;
	struct type_node *next;
};
struct single_operand{
	char *value;
	struct type_node *types; 
	struct type_node *return_types;
};
struct double_operand{
	char *value;
	struct type_node *right_types;
	struct type_node *left_types;
	struct type_node *return_types;
	int p;
};
struct expr *create_expr(char *type,char *value,struct expr *left,struct expr *right);



bool typecmp(char *value,struct type_node *head);
struct type_node *add_type(char *type,struct type_node *p);
struct single_operand *create_soper(char *value);
struct double_operand *create_doper(char *value,int p);
void add_right_type(char *type,struct double_operand *c);
void add_return_type(char *type,struct single_operand *c);
void add_double_return_type(char *type,struct double_operand *c);
void add_single_type(char *type,struct single_operand *c);
void add_left_type(char *type,struct double_operand *c);
struct expr *set_priority(int p, struct expr *c);
struct expr *set_new_highest(struct expr *c);
