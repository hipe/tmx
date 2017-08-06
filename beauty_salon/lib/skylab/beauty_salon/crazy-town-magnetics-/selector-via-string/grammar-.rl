%%{

  machine my_grammar;

  access@_zizzy_;
    # this is clever:
    #   - i came up with it. me.
    #   - access every variable as a member variable
    #   - we use a goofy arbitrary string just so you can track it

  # --
  # (actions are high-level to low-level because we can)

  action callish_identifier_action {
    _buff = remove_instance_variable :@_current_string_buffer
    @stderr.puts "callish identifier: #{ _buff }"
  }

  action clear {
    __clear_string_buffer
  }

  action term {
    __terminate_string_buffer
  }

  # --

  callish_identifier =
    ( [a-z] [_a-z0-9]* )
    >err{ oops( "callish identifier" ); }
    >clear %term
    %callish_identifier_action
    ;

  main :=
   callish_identifier
   0
   >err{ oops( "end of string" ); }
   @{ res = 1; }
   ;

}%%

module Skylab__BeautySalon

  class CrazyTownMagnetics___Selector_via_String__ThisThing___

    def initialize _, sout, serr

      @stderr = serr
      @stdout = sout
      %% write data;
    end

    def process input_s

      @_zizzy_data = input_s.unpack 'c*'

      @_zizzy_data.push 0
        # make this look like a null-terminated string in C
        # (there might be a more elegant/idiomatic way, but for now we
        # just want to fly close to the C-hosted version of this.)

      eof = @_zizzy_data.length
      # stack = []
      %% write init;
      @_binding = binding  # you're gonna want the `p` and `pe` local generated above #here1
      # hello i'm bewteen init and exec
      %% write exec;
      @_zizzy_cs
    end

    def oops msg

      io = @stderr

      input_s = __get_original_string

      io.puts "err #{ msg }:"

      buffer = '  '  # also margin

      io.puts "#{ buffer }#{ input_s }"

      buffer << ( '-' * _current_position )
      buffer << '^'

      io.puts buffer ; nil
    end

    def __clear_string_buffer
      @__begin_offset_for_string_buffer = _current_position
    end

    def __terminate_string_buffer
      _begin = remove_instance_variable :@__begin_offset_for_string_buffer
      _end = _current_position
      @_current_string_buffer =
        @_zizzy_data[ _begin ... _end ].pack( C_STAR_ ).freeze
    end

    def _current_position
      @_binding.local_variable_get :p
    end

    def __get_original_string
      d_a = @_zizzy_data
      d_a.last.zero? || fail
      d_a[ 0 ... -1 ].pack C_STAR_
    end

    C_STAR_ = 'c*'.freeze

  end
end

argv = ::ARGV

if __FILE__ != $PROGRAM_NAME
  # nothing - assume this is being loaded for some other purpose
elsif 1 == argv.length && /\A--?h(?:e(?:l(?:p)?)?)?\z/ !~ argv[0]
  _accepter = Skylab__BeautySalon::CrazyTownMagnetics___Selector_via_String__ThisThing___.new nil, $stdout, $stderr
  _x = _accepter.process argv.fetch 0
  $stdout.puts "OHAI: #{ _x.inspect }"
else
  $stderr.puts "usage: #{ $PROGRAM_NAME } <integer>"
end

# #born
