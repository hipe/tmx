require 'skylab/callback'

module Skylab::Zerk  # intro in [#001] README

  class << self

    def call args, acs, & p

      _oes_p_p = _handler_builder_for acs, & p

      bc = Produce_Bound_Call___[ args, acs, & _oes_p_p ]
      if bc
        bc.receiver.send bc.method_name, * bc.args, & bc.block
      else
        bc
      end
    end

    def persist args, acs, & p

      _oes_p_p = _handler_builder_for acs, & p

      Persist___[ args, acs, & _oes_p_p ]
    end

    def test_support
      if ! Home_.const_defined? :TestSupport
        load ::File.expand_path( '../../../test/test-support.rb', __FILE__ )
      end
      Home_.const_get :TestSupport, false
    end

    def unmarshal st, acs, & p

      _oes_p = _handler_builder_for acs, & p

      Unmarshal___[ st, acs, & _oes_p ]
    end

    def _handler_builder_for acs

      Require_ACS_[]

      if block_given?
        self._DESIGN_ME
      end

      acs.method :event_handler_for
    end

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  class CLI
    class << self
      alias_method :_orig_new, :new

      def new & p
        cls = ::Class.new self
        class << cls
          alias_method :new, :_orig_new
        end
        cls.send :define_method, :__top_builder_proc do
          p
        end
        cls
      end
    end  # >>

    def initialize sin, sout, serr, pn_s_a

      @program_name_string_array = pn_s_a
      @serr = serr
      @sin = sin
      @sout = sout
    end

    attr_reader(
      :argv, :program_name_string_array, :serr, :sin, :sout,

      :boundarizer,
    )

    def invoke argv

      if argv.length.zero?

        bc = ___bound_call_for_event_loop
        x = bc.receiver
        yield x if block_given?  # :/
        x.send bc.method_name, * bc.args, & bc.block

      elsif %r(\A-(?:h|-h(?:e(?:l(?:p)?)?)?)\z)i =~ argv.first

        @serr.puts "usage: '#{ @program_name_string_array * SPACE_ }'"
        SUCCESS_EXITSTATUS
      else
        self._DESIGN_ME
      end
    end

    def ___bound_call_for_event_loop

      @boundarizer =
        Home_.lib_.brazen::CLI_Support::Section::Boundarizer.new(
          line_yielder )

      _vmm = Home_::View_Maker_Maker___.new

      _el = Home_::Event_Loop___.new _vmm, self, & __top_builder_proc

      Callback_::Bound_Call.via_receiver_and_method_name _el, :run
    end

    def receive_uncategorized_emission i_a, & ev_p

      bc = Callback_::Emission::Interpreter.common[ i_a, & ev_p ]
      _ = send bc.method_name, * bc.args, & bc.block
      UNRELIABLE_
    end

    def receive_conventional_emission i_a, & ev_p

      _ev = ev_p[]
      _y = line_yielder
      _expag = _expression_agent

      _ev.express_into_under _y, _expag

      @boundarizer.touch_boundary

      UNRELIABLE_
    end

    def receive_expression_emission i_a, & y_p

      # (came from [#002]#detail-one)

      _y = line_yielder
      _expag = _expression_agent

      _expag.calculate _y, & y_p

      UNRELIABLE_
    end

    def _expression_agent
      Home_.lib_.brazen::CLI.expression_agent_instance
    end

    def line_yielder
      @___line_yielder ||= ___build_line_yielder
    end

    def ___build_line_yielder
      io = @serr
      ::Enumerator::Yielder.new do | string |
        io.puts string
      end
    end
  end

  Interpret_buttonesque_ = -> s, ada do

    o = Home_.lib_.brazen::Collection::Common_fuzzy_retrieve.new

    # -- setup

    o.qualified_knownness = Callback_::Qualified_Knownness.
      via_value_and_symbol( s, :argument )  # ..
        # against this string

    o.name_map = -> nameable do

      # given each qkn for each component, map it to a
      # string that should be used for the comparison

      nameable.name.as_slug
    end

    o.stream_builder = -> do
      Callback_::Stream.via_nonsparse_array ada.last_buttonesques_
    end

    # -- resultage

    o.on_event_selectively = -> * i_a, & ev_p do

      # in case of any kind of error (not found, ambiguity..)

      ada.receive_uncategorized_emission i_a, & ev_p

      if :info == i_a.first
        self._COVER_ME
      else
        UNABLE_  # so that we know to stop below (old-school)
      end
    end

    _ = o.execute
    _
  end

  class Produce_Bound_Call___

    # (no fuzzy)

    class << self

      def _call args, acs, & oes_p_p

        _st = Callback_::Polymorphic_Stream.via_array args
        new( _st, acs, & oes_p_p ).bound_call
      end

      alias_method :[], :_call
      alias_method :call, :_call
      alias_method :__new_via, :new
      private :new
    end  # >>

    def initialize st, acs, & oes_p_p

      @ACS = acs
      @_argument_stream = st
      @__oes_p = nil
      @_oes_p_p = oes_p_p
    end

    def __bc_via_recurse_into qkn

      remove_instance_variable :@__oes_p

      _ACS = remove_instance_variable :@ACS
      _st = remove_instance_variable :@_argument_stream  # unless #pop-back
      _oes_p_p = remove_instance_variable :@_oes_p_p  # #when-context

      _cmp = if qkn.is_effectively_known
        qkn.value_x  # [sa]
      else
        ACS_::For_Interface::Build_and_attach[ qkn.association, _ACS ]
        # #needs-upwards
      end

      _ = self.class.__new_via _st, _cmp, & _oes_p_p
      _.bound_call
    end

    def bound_call
      if @_argument_stream.no_unparsed_exists
        __when_no_arguments_for_ACS
      else
        __bc_via_the_parse_loop
      end
    end

    def __bc_via_the_parse_loop

      begin

        node = ___custom_parse_node
        if ! node
          bc = __when_no_match_under_ACS
          break
        end

        if node.association.model_classifications.looks_compound
          bc = __bc_via_recurse_into node
          break
          # (hypothetically we could allow returning to this frame. :#pop-back)
        end

        if @_argument_stream.no_unparsed_exists

          bc = __custom_parse_when_no_arguments node
          break
        end

        ok = __custom_parse_when_arguments node
        if ! ok
          bc = ok
          break
        end

        if @_argument_stream.no_unparsed_exists
          bc = Callback_::Bound_Call.via_value ACHIEVED_  # not sure..
          break
        end

        redo
      end while nil
      bc
    end

    # -- ("custom" means the result shape is ad-hoc and very mixed..)

    def ___custom_parse_node  # assume at least one token in upstream

      token_symbol = @_argument_stream.current_token

      st = ACS_::For_Interface::To_stream[ @ACS ]

      begin
        node = st.gets
        node or break

        if token_symbol == node.name.as_variegated_symbol
          break
        end

        redo
      end while nil

      if node
        @_argument_stream.advance_one
      end

      node
    end

    def __custom_parse_when_no_arguments terminal_node

      # #EXPERIMENTAL: the good news is we will stop the parse no matter
      # what. now, think of a "buttonlike" as an operation defined by an
      # association (and model or proc). a buttonlike from this state is
      # OK: the parse must now result with the appropriate bound call of
      # the buttonlike's chosing. conversely, a field-like must stop the
      # parse with failure talkin bout missing required argument. can we
      # accomplish that through a purely autonomous means, inferring the
      # argument arity from only the behavior pattern (where each field-
      # like does not have to whine for itself)?

      o = _begin_build_value terminal_node
      d = o.emission_handler_builder.count
      wv = o.execute
      if wv  # something succeeded.

        if wv.is_known_known  # by this decree it MUST be from a buttonlike..
          wv.value_x          # .. AND FURTHERMORE be a bound call!
        else

          # otherwise it is the known unknown. we don't remember what
          # #[#ac-002]Detail-one is for but we know that from this state:

          _when_missing_expected_argument_for terminal_node
        end

      elsif d == emission_handler_builder.count

        # othewise (and it failed to interpret), since it didn't emit
        # anything we hereby decree that is assumed to be something like
        # a field and wanted arguments so we:

        _when_missing_expected_argument_for node
      else

        # otherwise (and it failed to interpret and something was emitted),
        # we assume that whatever was emitted was sufficiently meaningful.
        wv
      end
    end

    def __custom_parse_when_arguments terminal_node

      # #EXPERIMENTAL (again) - if the node is fieldlike that is OK. but if
      # the button is buttonlike then we have unexpected arguments. can we
      # determine which is which using the response pattern alone?

      o = _begin_build_value terminal_node
      d = o.emission_handler_builder.count
      wv = o.execute

      if wv
        ___accept wv, terminal_node

      elsif d == o.emission_handler_builder.count

        # the node failed to interpret the input and nothing was emitted.
        # assume it is button-like and wanted no arguments.

        _when_extra_arguments_for terminal_node
      else
        wv  # assume that whatever was emitted was what we think it is
      end
    end

    def ___accept wv, node

      p = ACS_::Interpretation::Accept_component_change[
        wv.value_x,
        node,
        @ACS,
      ]

      _handler.call :info, :set_leaf_component do
        p[]
      end

      KEEP_PARSING_
    end

    def _begin_build_value node

      @__hbwc ||= ___build_handler_builder_with_counter

      ACS_::Interpretation_::Build_value.begin(
        @_argument_stream,
        node.association,
        @ACS,
        & @__hbwc )
    end

    def ___build_handler_builder_with_counter

      # experiment - can we distinguish buttons with unexpected arguments
      # from fields with invalid arguments using only this? (also try to
      # distinguish a field missing an argument vs. a button with this too!)

      oes_p_p_o = Emission_Counter___.new do |_|

        oes_p = @_oes_p_p[ nil ]

        -> * i_a, & ev_p do
          oes_p_p_o.count += 1
          oes_p[ * i_a, & ev_p ]
          UNRELIABLE_
        end
      end
      oes_p_p_o.count = 0
      oes_p_p_o
    end

    class Emission_Counter___ < ::Proc
      attr_accessor :count
    end

    # -- when

    def __when_no_arguments_for_ACS

      _get_handler.call :error, :expression, :empty_arguments do | y |
        y << "#{ highlight 'empty' } argument list."
      end
      UNABLE_
    end

    def __when_no_match_under_ACS

      _get_handler.call :error, :uninterpretable_token do
        __build_uninterpretable_token_event
      end

      UNABLE_  # hypothetially could be a b.c instead..
    end

    def _when_missing_expected_argument_for node

      _get_handler.call :error, :expression, :request_ended_prematurely do | y |

        y << "expecting value for #{ par node.name }"
      end

      UNABLE_  # important
    end

    def _when_extra_arguments_for node

      x = @_argument_stream.current_token

      _get_handler.call :error, :expression, :request_had_unexpected_argument do |y|

        y << "unexpected argument #{ ick x }"
      end

      UNABLE_
    end

    def __build_uninterpretable_token_event

      _st = ACS_::For_Interface::To_stream[ @ACS ]

      _st_ = _st.map_by do | qkn |
        qkn.name.as_variegated_symbol
      end

      _st__ = _st_.flush_to_polymorphic_stream

      o = Home_.lib_.fields::MetaMetaFields::Enum::Build_extra_value_event.new

      o.invalid_value = @_argument_stream.current_token

      o.valid_collection = _st__

      o.property_name = Callback_::Name.via_human 'argument'

      o.event_name_symbol = :uninterpretable_token

      o.execute
    end

    def _handler
      @__oes_p ||= @_oes_p_p[ @ACS ]
    end

    def _get_handler
      if @__oes_p
        @__oes_p
      else
        @_oes_p_p[ @ACS ]
      end
    end
  end

  Unmarshal___ = -> st, acs, & oes_p_p do

    if st.respond_to? :read
      json = st.read
    else
      json = ""
      while line = st.gets
        json.concat line
      end
    end

    _oes_p = oes_p_p[ acs ]

    o = ACS_::Modalities::JSON::Interpret.new( & _oes_p )
    o.ACS = acs
    o.JSON = json

    o.context_linked_list = begin

      _context_value = -> do
        'in input JSON'
      end

      Home_.lib_.basic::List::Linked[ nil, _context_value ]
    end

    o.execute
  end

  Persist___ = -> args, acs, & oes_p_p do

    y = args.shift

    _oes_p = oes_p_p[ acs ]

    o = ACS_::Modalities::JSON::Express.new( & _oes_p )

    o.downstream_IO_proc = -> do
      y
    end

    o.upstream_ACS = acs

    if args.length.nonzero?
      args.each_slice 2 do | k, x |
        o.send :"#{ k }=", x
      end
    end

    o.execute
  end

  Lazy_ = Callback_::Lazy

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.ACS
    NIL_
  end

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Open_3 = stdlib[ :Open3 ]

    system_lib = sidesys[ :System ]
    System = -> do
      system_lib[].services
    end
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  BLANK_RX_ = /\A[[:space:]]*\z/
  EMPTY_A_ = [].freeze
  FINISHED_ = nil
  Home_ = self
  KEEP_PARSING_ = true
  NIL_ = nil
  NONE_S = '(none)'.freeze
  NOTHING_TO_DO_ = nil
  SUCCESS_EXITSTATUS = 0
  SPACE_ = ' '
  UNABLE_ = false
  UNRELIABLE_ = :_unreliable_  # if you're evaluating this, you shouldn't be
end
