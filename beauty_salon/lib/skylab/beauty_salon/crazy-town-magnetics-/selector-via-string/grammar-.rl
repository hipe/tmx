%%{

  machine test_lexer;

  integer = ('+'|'-')?[0-9]+;

  main := |*
    integer => { puts "Integer" };
  *|;

}%%

%% write data;

def run_lexer(data)

  data = data.unpack("c*") if(data.is_a?(String))
  eof = data.length
  token_array = []

  %% write init;
  %% write exec;

  puts token_array.inspect
end

argv = ::ARGV
if 1 == argv.length && /\A--?h(?:e(?:l(?:p)?)?)?\z/ !~ argv[0]
  run_lexer argv.fetch 0
else
  $stderr.puts "usage: #{ $PROGRAM_NAME } <integer>"
end

# #born
