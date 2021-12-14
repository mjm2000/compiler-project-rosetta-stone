CC=gcc
EXECUTABLE=comp
LEXER_SOURCE=build/lex.yy.c
LANGUAGE_DESCRIPTION=src/lexicalStructure.lex
PARSER_SOURCE=build/parser.tab.c
GRAMMAR_DESCRIPTION=src/parser.y
OBJECTS=build/expression.o build/SymbolTable.o
FLAGS=-g

all:
	make clean
#	make $(PARSER_SOURCE)
#	make $(LEXER_SOURCE)
	make $(EXECUTABLE)

.PHONY: clean
clean:
	rm -fr build comp ./compiler_output.txt

$(PARSER_SOURCE): $(GRAMMAR_DESCRIPTION)
	mkdir -p build
	bison --debug -dv $(GRAMMAR_DESCRIPTION) -o  $(PARSER_SOURCE)

$(LEXER_SOURCE): $(LANGUAGE_DESCRIPTION) $(PARSER_SOURCE)
	mkdir -p build
	flex  -o $(LEXER_SOURCE) $(LANGUAGE_DESCRIPTION) 

build/expression.o: src/expression.c 
	gcc $(FLAGS) -c  src/expression.c -o build/expression.o

build/SymbolTable.o: src/SymbolTable.c 
	gcc $(FLAGS) -c  src/SymbolTable.c -o build/SymbolTable.o

$(EXECUTABLE): $(LEXER_SOURCE) $(PARSER_SOURCE) $(OBJECTS) runner.c
	$(CC) $(FLAGS) -Ibuild -Isrc src/runner.c $(OBJECTS) $(LEXER_SOURCE) $(PARSER_SOURCE) -o $(EXECUTABLE)

lex.yy.c runner.c		: build/parser.tab.h



