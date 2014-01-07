use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

foreach my $filename (@ARGV) {
    print $filename, "\n";
    open my $fh, '<', $filename or die "Cannot load $filename";
    my $code = do { local $/; <$fh> };
    my $ast = Compiler::Parser->new->parse(Compiler::Lexer->new->tokenize($code));
=hoge
    if (my $pid = fork()) {
        #close $writer;
        waitpid($pid, 0);
    } else {
        my $ast = Compiler::Parser->new->parse(Compiler::Lexer->new->tokenize($code));
        print "success!!\n";
        #close $reader;
        #open STDOUT, '>&', $writer;
        #$generator->debug_run($ast);
        exit;
    }
=cut
    #Compiler::Parser::AST::Renderer->new->render($ast);
}
