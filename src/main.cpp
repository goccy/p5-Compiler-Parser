#include <lexer.hpp>
#include <parser.hpp>
#define MAX_LINE_SIZE 128
#define MAX_SCRIPT_SIZE 4096 * 10

int main(int argc, char **argv)
{
	const char *filename = argv[1];
	char line[MAX_LINE_SIZE] = {0};
	char script_[MAX_SCRIPT_SIZE] = {0};
	char *tmp = script_;
	char *script = script_;
	FILE *fp = fopen(filename, "r");
	if (!fp) {
		fprintf(stderr, "script not found: %s\n", filename);
		exit(EXIT_FAILURE);
	}
	while (fgets(line, MAX_LINE_SIZE, fp) != NULL) {
		//DBG_PL("line = [%s]", line);
		int line_size = strlen(line);
		snprintf(tmp, line_size + 1, "%s\n", line);
		tmp += line_size;
	}
	fclose(fp);
	Lexer *lexer = new Lexer(filename);
	Tokens *tokens = lexer->tokenize(script);
	lexer->annotateTokens(tokens);
	lexer->grouping(tokens);
	lexer->prepare(tokens);
	//lexer->dump(tokens);
	Token *root = lexer->parseSyntax(NULL, tokens);
	//lexer->dumpSyntax(root, 0);
	lexer->parseSpecificStmt(root);
	//lexer->dumpSyntax(root, 0);
	lexer->setIndent(root, 0);
	size_t block_id = 0;
	lexer->setBlockIDWithDepthFirst(root, &block_id);
	Parser *parser = new Parser();
	AST *ast = parser->parse(root);
	ast->dump();
}
