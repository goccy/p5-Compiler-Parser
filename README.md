# NAME

Compiler::Parser - Create Abstract Syntax Tree for Perl5

# SYNOPSIS

    use Compiler::Lexer;
    use Compiler::Parser;
    use Compiler::Parser::AST::Renderer;

    my $filename = $ARGV[0];
    open(my $fh, "<", $filename) or die("$filename is not found.");
    my $script = do { local $/; <$fh> };
    my $lexer = Compiler::Lexer->new($filename);
    my $tokens = $lexer->tokenize($script);
    my $parser = Compiler::Parser->new();
    my $ast = $parser->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);

# DESCRIPTION

Compiler::Parser creates abstract syntax tree for perl5.

# SEE ALSO

\[Compiler::Lexer\](http://search.cpan.org/perldoc?Compiler::Lexer)

# AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

# COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
