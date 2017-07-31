%%{

  machine my_grammar;

  integer = ('+'|'-')?[0-9]+;

  main := |*
    integer => { puts "Integer" };
  *|;

}%%

module Skylab__BeautySalon

  class CrazyTownMagnetics___Selector_via_String__ThisThing___

    def initialize
      %% write data;
    end

    def process input_s
      data = input_s.unpack 'c*'
      eof = data.length
      # stack = []
      %% write init;
      %% write exec;
      cs
    end
  end
end

argv = ::ARGV
if 1 == argv.length && /\A--?h(?:e(?:l(?:p)?)?)?\z/ !~ argv[0]
  _accepter = Skylab__BeautySalon::CrazyTownMagnetics___Selector_via_String__ThisThing___.new
  _x = _accepter.process argv.fetch 0
  $stdout.puts "OHAI: #{ _x.inspect }"
else
  $stderr.puts "usage: #{ $PROGRAM_NAME } <integer>"
end

# #born
