%%{

  machine my_grammar;

  access @_zizzy_;
    # this is clever:
    #   - i came up with it. me.
    #   - access every variable as a member variable
    #   - we use a goofy arbitrary string just so you can track it


  callish_identifier = [a-z] [_a-z0-9]* ;
    # pending all these:
    #   - break out into other symbol
    #   - capture the contents
    #   - error emitting (YIKES)

  main :=
   callish_identifier
   0
   @{ res = 1; }
   ;

}%%

module Skylab__BeautySalon

  class CrazyTownMagnetics___Selector_via_String__ThisThing___

    def initialize
      %% write data;
    end

    def process input_s
      @_zizzy_data = input_s.unpack 'c*'
      eof = @_zizzy_data.length
      # stack = []
      %% write init;
      %% write exec;
      @_zizzy_cs
    end
  end
end

argv = ::ARGV

if __FILE__ != $PROGRAM_NAME
  # nothing - assume this is being loaded for some other purpose
elsif 1 == argv.length && /\A--?h(?:e(?:l(?:p)?)?)?\z/ !~ argv[0]
  _accepter = Skylab__BeautySalon::CrazyTownMagnetics___Selector_via_String__ThisThing___.new
  _x = _accepter.process argv.fetch 0
  $stdout.puts "OHAI: #{ _x.inspect }"
else
  $stderr.puts "usage: #{ $PROGRAM_NAME } <integer>"
end

# #born
