load File.dirname(__FILE__)+'/bin/yacc-to-treetop'

ytt = Hipe::YaccToTreetop::Translator.new
ytt.execution_context.out = File.new('foo.rb', 'w')
ytt.run
