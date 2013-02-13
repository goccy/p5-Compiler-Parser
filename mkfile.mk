CC = g++-4.2
CFLAGS = -O0 -g3 -Wall -W -I./include/ -DDEBUG_MODE
LDLIBS =
target = parser

objs = build/main.o \
	build/Compiler_gen_token_decl.o \
	build/Compiler_lexer.o \
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

build/Compiler_gen_token_decl.o : src/Compiler_gen_token_decl.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_lexer.o : src/Compiler_lexer.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_completer.o : src/Compiler_completer.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_parser.o : src/Compiler_parser.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_node.o : src/Compiler_node.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

build/Compiler_util.o : src/Compiler_util.cpp
	$(CC) $(CFLAGS) -o $@ -c $^

.PHONY: clean
clean:
	$(RM) -rf $(objs) $(target) *~
