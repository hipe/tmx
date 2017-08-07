%%{

  machine my_grammar;

  access@THE_;
    # this is clever:
    #   - i came up with it. me.
    #   - access every variable as a member variable
    #   - it is a sort of goofy looking name so you can track its origin
    #   - the lack of space between `acceess` and `@_..` is yuck intentional

  # --
  # (actions are high-level to low-level because we can)

  action callish_identifier_action {
    @on_callish_identifier[ _release_string_buffer ]
  }

  action started_OR {
    @on_is_AND_not_OR[ false ]
  }

  action started_AND {
    @on_is_AND_not_OR[ true ]
  }

  action test_identifier_action {
    @on_test_identifier[ _release_string_buffer ]
  }

  action literal_string_body_action {
    @on_literal_string[ _release_string_buffer ]
  }

  action true_keyword_action {
    @on_true_keyword[]
    nil
  }

  action begin_capture {
    @__begin_offset_for_string_buffer = p  # current_position_
  }

  action end_capture {
    __terminate_string_buffer
  }

  action begin_char_by_char_capture {
    @_bytes = []
  }

  action append_character {
    @_bytes.push @THE_data.fetch p
  }

  action end_char_by_char_capture {
    _d_a = remove_instance_variable :@_bytes
    @_current_string_buffer = _d_a.pack( C_STAR ).freeze
  }

  # --

  ws = [ \t] ;

  true_keyword =
    'true'i
    >err{ oops( "expecting true keyword" ); }
    %true_keyword_action
    ;

  identifier = [a-z] [_a-z0-9]* ;
    # note for now we allow no uppercase but there's a fair chance this will change..

  callish_identifier =
    identifier
    >err{ oops( "expecting callish identifier ([a-z][_a-z0-9]*)" ); }
    >begin_capture %end_capture
    %callish_identifier_action
    ;

  single_quote_char =
    # (this yuck is explained in our sibling file "grammar-in-c.rl")
    [ -&(-[\]-~]
    $append_character
    |
    '\\' any
    @append_character
    ;

  equals_predicate =
    '=='
    >err{ oops( "expecting '=='" ); }
    <>err{ oops( "expecting '='" ); }
    ws*
    "'"
    >err{ oops( "expecting open single quote" ); }
    single_quote_char *
    # >err{ oops( "expecting single quote body" ); } should never be needed b.c empty strings allows (but etc)
    >begin_char_by_char_capture %end_char_by_char_capture
    %literal_string_body_action
    "'"
    >err{ oops( "expecting close single quote" ); }
    ;

  test =
    identifier
    >err{ oops( "expecting identifier" ); }
    >begin_capture %end_capture
    %test_identifier_action
    ws*
    ( equals_predicate )
    ;

  AND_tests =
    (
      ws*
      '&&'
      >started_AND
      >err{ oops( "expecting '&&'" ); }
      <>err{ oops( "expecting '&'" ); }
      ws*
      test
    )+
    ;

  OR_tests =
    (
      ws*
      '||'
      >started_OR
      >err{ oops( "expecting '||'" ); }
      <>err{ oops( "expecting '|'" ); }
      ws*
      test
    )+
    ;

  tests = test ( AND_tests | OR_tests )? ;

  root_test =
    ( tests | true_keyword )
    ;

  main :=
    callish_identifier
    '('
    >err{ oops( "expecting open parenthesis" ); }
    ws*
    root_test
    ws*
    ')'
    >err{ oops( "expecting close parenthesis" ); }
    0
    >err{ oops( "expecting end of input" ); }
    @{ @_did_finish = true; }
    ;

}%%

module Skylab__BeautySalon

  # (it's not strictly necessary, but creating our own modules and being
  # standalone (rather than using the modules and facilities of our host
  # sidesystem) makes it easier for us to implement the detection of
  # warnings for reasons explained at #spot1.3 but keep in mind this could change.)

  class CrazyTownMagnetics___Selector_via_String__Grammar_

    class << self
      def call_by & p
        new( & p ).execute
      end
      private :new
    end  # >>

    def initialize
      yield self
      # hello: begin write data
      %% write data;
      # hello: end write data
      @_did_finish = false
    end

    attr_writer(
      :input_string,
      :listener,
      :on_callish_identifier,
      :on_error_message,
      :on_literal_string,
      :on_is_AND_not_OR,
      :on_test_identifier,
      :on_true_keyword,
    )

    def execute

      @THE_data = @input_string.unpack C_STAR

      @THE_data.push 0
        # make this look like a null-terminated string in C
        # (there might be a more elegant/idiomatic way, but for now we
        # just want to fly close to the C-hosted version of this.)

      eof = @THE_data.length
      # stack = []
      %% write init;
      @_binding = binding  # you're gonna want the `p` and `pe` local generated above #here1
      # hello i'm bewteen init and exec
      %% write exec;
      @_did_finish
    end

    # -- parsing support (methods that appear in actions)

    def __terminate_string_buffer
      _begin = remove_instance_variable :@__begin_offset_for_string_buffer
      _end = current_position_
      @_current_string_buffer =
        @THE_data[ _begin ... _end ].pack( C_STAR ).freeze
    end

    def _release_string_buffer
      remove_instance_variable :@_current_string_buffer
    end

    # --

    def oops msg
      @on_error_message[ msg ]
    end

    def current_position_
      @_binding.local_variable_get :p
    end

    attr_reader(
      :THE_data,
    )

    C_STAR = 'c*'

  end
end
# #born
