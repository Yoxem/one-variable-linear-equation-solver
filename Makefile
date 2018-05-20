CC=gcc
OUTPUT=interp

all: y.tab.c lex.yy.c
	$(CC) -o $(OUTPUT) y.tab.c lex.yy.c

y.tab.c: interp.y
	bison -vdty interp.y

lex.yy.c: interp.l
	flex interp.l
