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
    _buff = remove_instance_variable :@_current_string_buffer
    @on_callish_identifier[ _buff ]
    nil
  }

  action clear {
    @__begin_offset_for_string_buffer = current_position_
  }

  action term {
    __terminate_string_buffer
  }

  # --

  callish_identifier =
    ( [a-z] [_a-z0-9]* )
    >err{ oops( "expecting callish identifier ([a-z][_a-z0-9]*)" ); }
    >clear %term
    %callish_identifier_action
    ;

  main :=
   callish_identifier
   0
   >err{ oops( "expecting end of string" ); }
   @{ res = 1; }
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
    end

    attr_writer(
      :input_string,
      :listener,
      :on_callish_identifier,
      :on_error_message,
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
      @THE_cs
    end

    # -- parsing support (methods that appear in actions)

    def __terminate_string_buffer
      _begin = remove_instance_variable :@__begin_offset_for_string_buffer
      _end = current_position_
      @_current_string_buffer =
        @THE_data[ _begin ... _end ].pack( C_STAR_ ).freeze
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
