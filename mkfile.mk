CC = g++
CFLAGS = -O0 -g3 -Wall -W -I./include/ -DDEBUG_MODE
LDLIBS =
target = parser

objs = build/main.o \
	build/Compiler_gen_token_decl.o \
	build/Compiler_lexer.o \
	build/Compiler_annotator.o \
	build/Compiler_parser.o \
	build/Compiler_completer.o \
	build/Compiler_node.o \
	build/Compiler_util.o \

.PHONY: all
all: $(target)

$(target): $(objs)
	$(CC) -o $@ $^ $(LDLIBS)

build/main.o : src/main.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_gen_token_decl.o : src/compiler/util/Compiler_gen_token_decl.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_lexer.o : src/compiler/lexer/Compiler_lexer.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_annotator.o : src/compiler/lexer/Compiler_annotator.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_completer.o : src/compiler/parser/Compiler_completer.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_parser.o : src/compiler/parser/Compiler_parser.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_node.o : src/compiler/parser/Compiler_node.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_util.o : src/compiler/util/Compiler_util.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

.PHONY: clean
clean:
	$(RM) -rf $(objs) $(target) *~
