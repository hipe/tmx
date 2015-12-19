require 'skylab/callback'

module Skylab::Zerk  # intro in [#001] README

  class << self

    def call args, acs, & p

      _oes_p_p = _handler_builder_for acs, & p

      bc = Call___[ args, acs, & _oes_p_p ]
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

  class Call___

    class << self

      def _call args, acs, & oes_p_p

        _st = Callback_::Polymorphic_Stream.via_array args
        _via( _st, acs, & oes_p_p ).resolve_bound_call
      end

      alias_method :[], :_call
      alias_method :call, :_call
      alias_method :_via, :new
      private :new
    end  # >>

    def initialize st, acs, & oes_p_p

      @ACS = acs
      @_argument_stream = st
      @__oes_p = nil
      @_oes_p_p = oes_p_p
    end

    def __recurse qkn

      me = remove_instance_variable :@ACS
      _st = remove_instance_variable :@_argument_stream  # unless #pop-back
      remove_instance_variable :@__oes_p
      _oes_p_p = remove_instance_variable :@_oes_p_p  # #when-context

      if qkn.is_known_known
        self._K
      else
        _cmp = ACS_::For_Interface::Build_and_attach[ qkn.association, me ]
        # #needs-upwards
      end

      _ = self.class._via( _st, _cmp, & _oes_p_p )
      _.resolve_bound_call
    end

    def resolve_bound_call
      if @_argument_stream.no_unparsed_exists
        ___when_no_arguments
      else
        __when_some_arguments
      end
    end

    def ___when_no_arguments

      _get_handler.call :error, :expression, :empty_arguments do | y |
        y << "#{ highlight 'empty' } argument list."
      end
      UNABLE_
    end

    def __when_some_arguments  # no fuzzy

      begin

        node = ___parse_node
        if ! node
          x = __when_no_match
          break
        end

        if node.association.model_classifications.looks_compound
          x = __recurse node
          # (hypothetically we could allow returning to this frame. :#pop-back)
          break
        else
          x = __parse_node_value node
          x or break
        end

        if @_argument_stream.no_unparsed_exists
          x = Callback_::Bound_Call.via_value ACHIEVED_  # not sure..
          break
        end

        redo
      end while nil
      x
    end

    def ___parse_node  # assume at least one token in upstream

      token_symbol = @_argument_stream.current_token

      st = _to_interface_stream

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

    def _to_interface_stream

      ACS_::For_Interface::To_stream[ @ACS ]
    end

    def __parse_node_value node  # t/f

      if @_argument_stream.no_unparsed_exists
        __when_missing_value node
      else
        wv = ACS_::Interpretation_::Build_value[
          @_argument_stream,
          node.association,
          @ACS,
          & @_oes_p_p ]

        if wv

          p = ACS_::Interpretation::Accept_component_change[
            wv.value_x,
            node,
            @ACS,
          ]

          _handler.call :info, :set_leaf_component do
            p[]
          end

          ACHIEVED_
        else
          wv
        end
      end
    end

    # -- similar eventages

    def __when_no_match

      _get_handler.call :error, :uninterpretable_token do
        __build_uninterpretable_token_event
      end

      UNABLE_  # hypothetially could be a b.c instead..
    end

    def __when_missing_value node

      _get_handler.call :error, :expression, :request_ended_prematurely do | y |

        y << "expecting value for #{ par node.name }"
      end

      UNABLE_  # important
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
  NIL_ = nil
  NONE_S = '(none)'.freeze
  NOTHING_TO_DO_ = nil
  SUCCESS_EXITSTATUS = 0
  SPACE_ = ' '
  UNABLE_ = false
  UNRELIABLE_ = :_unreliable_  # if you're evaluating this, you shouldn't be
end
