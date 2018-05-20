%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char* msg) {}
extern FILE* yyin;

typedef enum
{null, opera, var, val} NodeType;

typedef struct Node {
float val;
char * name; // val_name
char * opr; // operator
NodeType node_type;
struct Node * left;
struct Node * right;
} Node;

Node create_op_node(char * op){
Node node;
node.opr = op;
node.node_type = opera;
return node;
}

Node create_var_node(char * op){
Node node;
node.name = op;
node.node_type = var;
return node;
}

Node create_val_node(float value){
Node node;
node.val = value;
node.node_type = val;
return node;
}
void connect_node(Node* op, Node* l, Node* r){
op->left = l;
op->right = r;
}

char * var_name = "";

void run_through_tree (Node *node){
    switch (node->node_type){
        case var:
            printf("varable name:%s\n",node->name);
            break;
        case val:
            printf("num value:%f\n",node->val);
            break;
        case opera:
            printf("\noperator:%s\n",node->opr);
            printf("LFS\n");
            run_through_tree(node->left);
            printf("RHS\n");
            run_through_tree(node->right);
    }

}

float eval_node(float var_val, Node * node){
    switch ((*node).node_type){
        case var:
            if (var_name == ""){
                var_name = node->name;
                printf("%s",node->name);
                return var_val;
            }
            else if (var_name == node->name){
                return var_val;
            }
            else{
                printf("Error: Too many variable, eg. %s, %s.\n",
                    var_name,node->name);
                break;
            }


            break;
        case val:
            return (*node).val;
            break;
        case opera:
            if (node->opr == "+"){
                    return (eval_node(var_val,node->left) + eval_node(var_val,node->right));
            }
            else if (node->opr == "-"){
                    return (eval_node(var_val,node->left) - eval_node(var_val,node->right));
            }
            else if (node->opr == "*"){
                    return (eval_node(var_val,node->left) * eval_node(var_val,node->right));
            }
            else if (node->opr == "/"){
                    return (eval_node(var_val,node->left) / eval_node(var_val,node->right));
            }
            break;
    }
}

Node * main_node;


%}

%union{
    float floatVal;
    int   intVal;
    char * strVal;
    struct Node *node;
}

%token T_VAR
%token T_NUM
%token T_ADD T_SUB T_MUL T_DIV T_LPATH T_RPATH T_NEWLINE
%left T_ADD T_SUB
%left T_MUL T_DIV
%left NEG

%type <floatVal> T_NUM
%type <strVal> T_VAR
%type <node> E


%%

S    : S E T_NEWLINE { main_node = $2;run_through_tree(main_node); /*printf("TOTAL_VALUE: %f",eval_node(5.0,main_node));*/}
     | {}
     ;

E    :  E T_ADD E {Node * op_node = (Node *) malloc(sizeof(Node));*op_node = create_op_node("+"); connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_SUB E {Node * op_node = (Node *) malloc(sizeof(Node));*op_node = create_op_node("-"); connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_MUL E {Node * op_node 
= (Node *) malloc(sizeof(Node));*op_node = create_op_node("*"); connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_DIV E {Node * op_node = (Node *) malloc(sizeof(Node));*op_node = create_op_node("/"); connect_node(op_node,$1,$3);$$ = op_node;} 
     | T_SUB E %prec NEG {
                        Node * op_node = (Node *) malloc(sizeof(Node));
                        Node * zero_node = (Node *) malloc(sizeof(Node));
                        * zero_node = create_val_node(0.0);
                        * op_node = create_op_node("-");
                        connect_node(op_node,zero_node,$2);
                        $$ = op_node;}
     | T_NUM {Node * val_node = (Node *) malloc(sizeof(Node));* val_node = create_val_node($1); $$ = val_node;}
     | T_VAR {Node * var_node = (Node *) malloc(sizeof(Node));* var_node = create_var_node($1); $$ = var_node;}
     | T_LPATH E T_RPATH {$$ = $2;}
     ;

%%

int main(){
  yyin = stdin;
  do{
	yyparse();
    
  }while(!feof(yyin));

  return 0;
}
