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

      Require_ACS__[]

      if block_given?
        self._DESIGN_ME
      end

      acs.method :event_handler_for
    end

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
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

  # ->
    class Common_Node

      # :+#hook-out's: (methods you need to implement in your child class)
      #
      #   `to_body_item_value_string_when_can_receive_focus` - false-ish means do not display

      def initialize x

        self._NEVER

        @name ||= self.class.name_function
        @parent = x
        if x.is_interactive
          @is_interactive = true
          @sin = x.sin
          @serr = x.serr
          @y = x.primary_UI_yielder
        else
          @is_interactive = false
        end
      end

      class << self

        def name_function
          @nf ||= bld_inferred_name_function
        end

        def bld_inferred_name_function

          _const = Callback_::Name.via_module( self ).as_const

          _cnst = RX__.match( _const )[ 0 ]

          Callback_::Name.via_const_string _cnst
        end
        RX__ = /\A.+(?=_(?:Agent|Branch|Boolean|Button|Field|Node)_*\z)/  # :+#experimental

      end

      # ~ messages received as child from parent

      # ~~ boolean reflectors (alphabetical)

      def can_receive_focus
        true
      end

      def is_branch  # used for non-interactive mode
        false
      end

      def is_interactive
        @is_interactive
      end

      def is_navigational  # used in non-interactive mode
        false
      end

      def is_terminal_node  # used in non-interactive mode
        false
      end

      # ~~ getters of symbols & strings (little to big)

      def name_symbol
        @name.as_lowercase_with_underscores_symbol
      end

      def slug
        @name.as_slug
      end

      def to_body_item_value_string
        if can_receive_focus
          to_body_item_value_string_when_can_receive_focus
        end
      end

      # ~~ interactive program flow hook-ins (chronological)

      def before_focus  # #note-70
        nil
      end

      def receive_focus
        ok = display_panel
        ok && block_for_response
      end

      def exitstatus
        0
      end

      # ~~ hook-ins for non-interactive

      def receive_polymorphic_stream stream
        if stream.unparsed_exists
          against_nonempty_polymorphic_stream stream
        else
          against_empty_polymorphic_stream
        end
      end

    private

      # ~~ support for interactive behavior

      def display_panel
        display_separator
        display_nav
        display_description
        display_body
        prompt
      end

      def display_separator
        @y << nil
        nil
      end

      def display_nav
        a = [ self ]
        cur = @parent
        while cur.is_agent
          a.push cur
          cur = cur.parent
        end
        a.reverse!
        scn = Callback_::Stream.via_nonsparse_array a
        first = scn.gets
        @y << first.slug
        d = 0
        while sub_item = scn.gets
          space = SPACE_GLYPH__ * d
          d += 1
          @y << "#{ space }#{ CROOK_GLYPH__ }#{ sub_item.slug }"
        end
        nil
      end
      SPACE_GLYPH__ = '  '.freeze
      CROOK_GLYPH__ = '└ '.freeze  # copy-pasted from [#sy-016]

      def display_description
      end

      def display_body
      end

      # `prompt` defined by child classes

      def write_and_flush s  # for testing it is necessary to flush explicitly
        @serr.write s
        @serr.flush
        nil
      end

      def block_for_response
        receive_mutable_input_line @sin.gets
      end

      # ~~ support for non-interactive behavior

      def against_nonempty_polymorphic_stream stream  # this is the default
        # behavior for terminal ("do something") nodes.. tossed here just b/c.

        maybe_send_event :error do
          build_extra_values_event stream
        end
        UNABLE_
      end

      def build_extra_values_event stream
        Home_.lib_.brazen::Property.
          build_extra_values_event [ stream.current_token ], nil, 'iambic token'
      end

    public

      # ~ messages received as parent from child

      # ~~ boolean reflectors

      def is_agent
        true
      end

      # ~~ resources in support of UI, events, and program flow

      attr_reader :parent, :serr, :sin

      def primary_UI_yielder
        @y
      end

      def change_focus_to x
        @parent.change_focus_to x
      end

      # ~ sending & receiving events, public interface & support
      #
      #   follows [#bs-028.C] name conventions. see #note-185

      def maybe_receive_unsigned_event_via_channel i_a, & ev_p  # for familiars
        maybe_send_event_via_channel i_a, & ev_p
      end

      def handle_event_selectively_via_channel  # for children
        @parent.handle_event_selectively_via_channel
      end

    private

      def handle_unsigned_event_selectively
        @HUES_p ||= method :maybe_send_event
      end

      def maybe_send_event * i_a, & ev_p
        maybe_send_event_via_channel i_a, & ev_p
      end

      def maybe_send_event_via_channel i_a, & ev_p

        @parent.handle_event_selectively_via_channel.call i_a do

          ev = if ev_p
            ev_p[]
          else
            Callback_::Event.inline_via_normal_extended_mutable_channel i_a  # frontier of this #experiment
          end

          _NAME = @name

          ev.with_message_string_mapper -> s, d do
            if d.zero?
              if ev.ok || ev.ok.nil?
                "#{ _NAME.as_human } node #{ s }"
              else
                "#{ _NAME.as_human } error: #{ s }"
              end
            else
              "  #{ s }"
            end
          end
        end
      end

      def build_not_OK_event_with * x_a, & p
        Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
      end

      def build_OK_event_with * x_a, & p
        Callback_::Event.inline_OK_via_mutable_iambic_and_message_proc x_a, p
      end
    end

    class Branch_Node < Common_Node  # see #note-branch

      def is_branch
        true
      end

      def child_stream
        Callback_::Stream.via_nonsparse_array @children
      end

    private

      def receive_mutable_input_line s
        s.strip!
        rx = Home_.lib_.basic::Fuzzy.case_sensitive_regex_via_string s
        cx_a = []
        @children.each do |cx|  # ~#[#ba-015] the simple fuzzy algorithm
          cx.can_receive_focus or next
          rx =~ cx.slug or next
          if s == cx.slug
            cx_a.clear.push cx
            break
          end
          cx_a.push cx
        end
        case 1 <=> cx_a.length
        when -1
          when_ambiguous cx_a
        when 0
          when_one cx_a.first
        when 1
          when_none s
        end
      end

      def when_ambiguous cx_a
        @y << "did you mean #{ cx_a.map( & :slug ) * ' or ' }?"
        ACHIEVED_
      end

      def when_none s
        @y << "unrecognized command: #{ s.inspect }"
        @y << "please enter #{ build_prompt_line }"
        ACHIEVED_
      end

      def when_one cx
        @parent.change_focus_to cx
        ACHIEVED_
      end

      def display_body
        a_a = []
        max = 0
        @children.each do |cx|
          s = cx.to_body_item_value_string
          s or next
          slug_s = cx.slug
          max < slug_s.length and max = slug_s.length
          a_a.push [ slug_s, s ]
        end
        fmt = "  %#{ max }s  %s"
        a_a.each do |a|
          @y << fmt % a
        end ; nil
      end

      def prompt
        write_and_flush "#{ build_prompt_line }: "
        ACHIEVED_
      end

      def build_prompt_line  # #note-190

        a = []

        @children.each do |cx|
          cx.can_receive_focus or next
          a.push cx.slug
        end

        Home_.lib_.basic::Hash.determine_hotstrings( a ).map do | o |
          if o
            "[#{ o.hotstring }]#{ o.rest }"
          end
          # if one string is a head-anchored substring of the other it is
          # always ambiguous, not displayed except we produce nil as a clue
        end * SPACE_
      end

    public

      def [] name_i  # :+#courtesy
        @children.detect do |cx|
          name_i == cx.name_symbol
        end
      end

      def has_name name_i  # :+#courtesy
        @children.index do |cx|
          name_i == cx.name_symbol
        end
      end

      # ~ persistence stuff for branch node :+#courtesy

      def receive_try_to_persist
        Home_::Actors__::Persist.with(
          :path, persist_path,
          :children, @children,
          :serr, @serr,
          :on_event_selectively, handle_unsigned_event_selectively )
      end

    private

      def retrieve_values_from_FS_if_exist
        Home_::Actors__::Retrieve[
          persist_path,
          @children,
          handle_unsigned_event_selectively ]
      end

      def persist_path
        @persist_path ||= build_persist_path
      end

      def build_persist_path
        "#{ work_dir }/current-#{ persist_filename }-form.conf"
      end

      def persist_filename
        @name.as_slug
      end
    end

    class Field < Common_Node  # see #note-field

      # :+#hook-out's: (in addition to those listed in parent class)
      #
      #   `value_is_known` - will be used for prompt behavior, perhaps
      #                      used by custom branch nodes
      #
      #   `know_via_nonblank_mutable_string` - #note-390
      #
      #   `unknow_value` - called when opt-in delete is used.
      #                    un-memoize the value. result is not regarded.
      #
      #   `to_marshal_pair` - false-ish means "do not persist". must look
      #                       like [#cb-055] pair. justification at #note-222.
      #
      #   `marshal_load` - result in booleanish indicating success. if unable,
      #                    yield an event to the block if you want.


    private

      # ~ displaying the prompt (for interactive mode)

      def prompt
        if value_is_known
          prompt_when_value
        else
          prompt_when_no_value
        end
      end

      def prompt_when_value  #:+public-API
        write_and_flush "new #{ noun } (nothing to cancel): "
        ACHIEVED_
      end

      def prompt_when_no_value
        write_and_flush "#{ noun } (nothing to cancel): "
        ACHIEVED_
      end

      public def noun
        s = self.class::NOUN___
        s || "'#{ @name.as_human }' value"
      end

      NOUN___ = nil

      # ~ processing input (from three sources)

      def receive_mutable_input_line line
        @line = line
        @line.chomp!
        if @line.length.zero?
          when_entered_zero_length_string
        elsif BLANK_RX_ =~ @line
          when_entered_nonzero_length_blank_string
        else
          when_entered_string_with_content
        end
      end

      def against_nonempty_polymorphic_stream_assume_string scan
        s = scan.gets_one
        if s.length.zero?
          when_passed_zero_length_string
        elsif BLANK_RX_ =~ s
          when_passed_nonzero_length_blank_string s
        else
          when_passed_string_with_content s
        end
      end

      def when_entered_zero_length_string
        when_cancelled
      end

      def when_passed_zero_length_string
        maybe_send_event :error, :invalid_property_value, :empty_string_is_meaningless  # #open #[#br-066]
        UNABLE_
      end

      def when_entered_nonzero_length_blank_string
        # it's tempting to make this a "delete" but also kinda nasty -
        # such behavior should be opt-in, lest it is produced accidentally
        when_cancelled
      end

      def when_passed_nonzero_length_blank_string s
        maybe_send_event :error, :invalid_property_value, :blank_string_is_meaningless  # #open #[#br-066]
        UNABLE_
      end

      def when_cancelled
        @y << "edit #{ slug } cancelled."
        change_focus_to @parent
        ACHIEVED_
      end

      def when_entered_string_with_content
        s = @line ; @line = nil
        ok = know_via_nonblank_mutable_string s  # (hook-out)
        if ok
          when_value_changed
        else
          ACHIEVED_
        end
      end

      def when_passed_string_with_content s
        ok = know_via_nonblank_mutable_string s
        ok and when_value_changed
      end

      def against_empty_polymorphic_stream
        maybe_send_event :error do
          build_request_ended_prematurely_event
        end
        UNABLE_
      end

      def build_request_ended_prematurely_event

        build_not_OK_event_with(
          :request_ended_prematurely,
          :name, @name,

        ) do | y, o |

          _prp = Home_.lib_.basic::Minimal_Property.via_name_function o.name

          y << "request ended prematurely - expecting value for #{ par _prp }"
        end
      end

      def when_deleted  # :+#courtesy
        ok = unknow_value
        if ok
          @y << "deleted #{ slug } value"
          when_value_changed
        else
          @y << "cannot delete #{ slug } value"
          ACHIEVED_
        end
      end

      def when_value_changed
        if @is_interactive
          try_to_persist  # for now we procede whether or not it succeeds
          change_focus_to @parent
        end
        ACHIEVED_
      end

      def try_to_persist
        @parent.receive_try_to_persist
      end
    end

    class Boolean < Common_Node  # see #note-bool

      def initialize group=nil, parent
        @group = group
        @is_activated = false
        super parent
      end

      attr_reader :is_activated

      def receive_focus
        if @group
          @group.activate name_symbol
        elsif @is_activated
          receive_activation
        else
          receive_deactivation
        end
      end

      def receive_polymorphic_stream _
        if @group
          @group.activate name_symbol
        elsif @is_activated
          ACHIEVED_
        else
          receive_activation
        end
      end

      def receive_activation
        @is_activated = true
        ACHIEVED_
      end

      def receive_deactivation
        @is_activated = false
        ACHIEVED_
      end

      def to_marshal_pair
        if @group
          nil  # the group controller does this
        elsif @is_activated
          Callback_::Pair.via_value_and_name( :yes, name_symbol )
        end
      end
    end

    class Up_Button < Common_Node  # :+#note-button

      def initialize times=2, x, & p
        @times = times
        @hook_p = p
        super x
      end

      def is_navigational
        true
      end

      def to_body_item_value_string
      end

      def receive_focus
        scn = Callback_::Stream.via_times @times
        if scn.gets
          current = @parent
        end
        while scn.gets
          current = current.parent
        end
        if current
          change_focus_to current
          if @hook_p
            @hook_p[]
          else
            ACHIEVED_
          end
        else
          UNABLE_
        end
      end

      def to_marshal_pair  # if it's in a branch node that persists itself
      end
    end

    class Quit_Button < Common_Node  # :+#note-button

      def initialize * a , & p
        @hook_p = p
        super( * a, & nil )
      end

      def is_navigational
        true
      end

      def to_body_item_value_string
      end

      def display_panel
        # we override this and not `receive_focus` so we see the amusingly useless nav
        if @hook_p
          ok = @hook_p[]
        else
          ok = true
        end
        if ok
          super
          @y << 'goodbye.'
          FINISHED_
        else
          ACHIEVED_
        end
      end

      def prompt
      end

      def to_marshal_pair
      end
    end

    Callback_ = ::Skylab::Callback

    Require_ACS__ = Callback_::Lazy.call do
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
    SPACE_ = ' '
    UNABLE_ = false
  # -
end
