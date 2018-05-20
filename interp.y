%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

void yyerror(const char* msg);
extern FILE* yyin;
extern int yylex();

typedef enum
{null, opera, var, val} NodeType;
 typedef enum {false, true} bool;
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
bool escape_recursion = false;
float eval_node(float var_val, Node * node){
    
    switch ((*node).node_type){
        case var:
		  if (strcmp(var_name,"")==0){
			    var_name = node->name;
                return var_val;
            }
            else if (strcmp(var_name,node->name)==0){
                return var_val;
            }
            else{
                printf("Error: Too many variable, eg. %s, %s.\n",
                    var_name,node->name);
				escape_recursion = true;
				return NAN;
                break;
            }


            break;
        case val:
            return (*node).val;
            break;
	    case opera:{
		    float left_num, right_num;

			left_num = eval_node(var_val,node->left);
			if (escape_recursion){return NAN; break;}

			right_num = eval_node(var_val,node->right);
			if (escape_recursion){return NAN; break;}

			if (node->opr == "+"){
			  return left_num + right_num;
            }
            else if (node->opr == "-"){
                    return left_num - right_num;
            }
            else if (node->opr == "*"){
                    return left_num * right_num;
            }
            else if (node->opr == "/"){
                    return left_num / right_num;
            }
            break;}
		  
    }
}

Node * main_node;
float solve(Node * m_node){
  escape_recursion = false;
  var_name = "";
  float x0 = 0.0;
  float y0 = eval_node(x0,m_node);
  float x1 = 1.0;
  float y1 = eval_node(x1,m_node);
  float x2 = 10.0;
  float y2 = eval_node(x2,m_node);

  if (isnan(y0) || isnan(y1) || isnan(y2)){
	return NAN;
  }
  else if(strcmp(var_name,"")==0){
	var_name = "[var]";
	
	if (y0 == 0.0){
	  printf("%s can be any numbers; the following is just a solution.",
			 var_name);
	  return 0.0;
	}
	else{
	  return NAN;
	}
  }
  else{

	float slope1 = (y1-y0) / (x1-x0);
	float slope2 = (y2-y0) / (x2-x0);

	if (slope1 == slope2){
	  if (slope1 == 0.0){
		if (y0 == 0){
		  printf("%s can be any numbers; the following is just a solution.",
			 var_name);
		  return 0.0;		  
		}
		else{
		  return NAN;
		}
	  }
	  else{
		float ans = -y0 / slope1;
		return ans;
	  }
	}
	else{
	  printf("Error: the formula is not linear.\n");
	  return NAN;
	}
  }
}
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

S    : S E T_NEWLINE { main_node = $2;
                       printf("ANSWER: %s = %f",var_name,solve(main_node));}
     | {}
     ;

E    :  E T_ADD E {Node * op_node = (Node *) malloc(sizeof(Node));
                   *op_node = create_op_node("+");
				   connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_SUB E {Node * op_node = (Node *) malloc(sizeof(Node));
                   *op_node = create_op_node("-");
				    connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_MUL E {Node * op_node = (Node *) malloc(sizeof(Node));
                   *op_node = create_op_node("*");
				   connect_node(op_node,$1,$3);$$ = op_node;}
     |  E T_DIV E {Node * op_node = (Node *) malloc(sizeof(Node));
                   *op_node = create_op_node("/");
				   connect_node(op_node,$1,$3);$$ = op_node;} 
     | T_SUB E %prec NEG {
                        Node * op_node = (Node *) malloc(sizeof(Node));
                        Node * zero_node = (Node *) malloc(sizeof(Node));
                        * zero_node = create_val_node(0.0);
                        * op_node = create_op_node("-");
                        connect_node(op_node,zero_node,$2);
                        $$ = op_node;}
     | T_NUM {Node * val_node = (Node *) malloc(sizeof(Node));
              * val_node = create_val_node($1);
			  $$ = val_node;}
     | T_VAR {Node * var_node = (Node *) malloc(sizeof(Node));
              * var_node = create_var_node($1);
			  $$ = var_node;}
     | T_LPATH E T_RPATH {$$ = $2;}
     ;

%%

int main(){
  yyin = stdin;
  do{
	  printf(
	"A program to solve f(x) = 0 such that f(x) is a 1-var linear function.\n");
	  printf("Please Enter a 1-var linear function: ");
	yyparse();
    
  }while(!feof(yyin));

  return 0;
}

void yyerror (const char *msg)
{

  fprintf (stderr, "%s\n", msg);
}
