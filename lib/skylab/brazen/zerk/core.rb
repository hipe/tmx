module Skylab::Brazen

  module Zerk  # see [#062]

    class Common_Node

      # :+#hook-out's: (methods you need to implement in your child class)
      #
      #   `to_body_item_value_string_when_can_receive_focus` - false-ish means do not display

      def initialize x
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
          Callback_::Name.via_const _cnst
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

      def name_i
        @name.as_variegated_symbol
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

      def receive_iambic_stream stream
        if stream.unparsed_exists
          against_nonempty_iambic_stream stream
        else
          against_empty_iambic_stream
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
        scn = Callback_::Scan.via_nonsparse_array a
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
      CROOK_GLYPH__ = '└ '.freeze  # copy-pasted from [#hl-171]

      def display_description
      end

      def display_body
      end

      # `prompt` defined by child classes

      def block_for_response
        receive_mutable_input_line @sin.gets
      end

      # ~~ support for non-interactive behavior

      def against_nonempty_iambic_stream stream  # this is the default
        # behavior for terminal ("do something") nodes.. tossed here just b/c.

        maybe_send_event :error do
          build_extra_properties_event stream
        end
        UNABLE_
      end

      def build_extra_properties_event stream
        Brazen_::Entity.properties_stack.
          build_extra_properties_event [ stream.current_token ], nil, 'iambic token'
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
      #   follows [#hl-175] name conventions. see #note-185

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
          ev = ev_p[]
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
        Brazen_.event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
      end

      def build_OK_event_with * x_a, & p
        Brazen_.event.inline_OK_via_mutable_iambic_and_message_proc x_a, p
      end
    end

    class Branch_Node < Common_Node  # see #note-branch

      def is_branch
        true
      end

      def child_stream
        Callback_.scan.via_nonsparse_array @children
      end

    private

      def receive_mutable_input_line s
        s.strip!
        rx = /\A#{ ::Regexp.escape s }/i
        cx_a = []
        @children.each do |cx|
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
        PROCEDE_
      end

      def when_none s
        @y << "unrecognized command: #{ s.inspect }"
        @y << "please enter #{ build_prompt_line }"
        PROCEDE_
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
        @serr.write "#{ build_prompt_line }: "
        PROCEDE_
      end

      def build_prompt_line  # #note-190
        a = []
        @children.each do |cx|
          cx.can_receive_focus or next
          a.push cx.slug
        end

        Brazen_::Lib_::Bsc_[]::Hash.determine_hotstrings( a ).map do | o |
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
          name_i == cx.name_i
        end
      end

      def has_name name_i  # :+#courtesy
        @children.index do |cx|
          name_i == cx.name_i
        end
      end

      # ~ persistence stuff for branch node :+#courtesy

      def receive_try_to_persist
        Zerk_::Actors__::Persist.with(
          :path, persist_path,
          :children, @children,
          :serr, @serr,
          :on_event_selectively, handle_unsigned_event_selectively )
      end

    private

      def retrieve_values_from_FS_if_exist
        Zerk_::Actors__::Retrieve[
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
      #   `via_line_know_value` -  attempt to normalize and memoize the
      #                            string in @line. result is treated as
      #                            boolean-ish with true-ish as success.
      #                            on failure, default behavior is to stay.
      #
      #   `unknow_value` - when opt-in delete is used, un-memoize
      #                    the value. result is not regarded.
      #
      #   `to_marshal_pair` - false-ish means "do not persist". must look
      #                       like [#cb-055] pair. justification at #note-222.
      #
      #   `marshal_load` - result in booleanish indicating success. if unable,
      #                    yield an event to the block if you want.


    private

      def against_empty_iambic_stream
        maybe_send_event :error do
          build_request_ended_prematurely_event
        end
        UNABLE_
      end

      def build_request_ended_prematurely_event
        build_not_OK_event_with :request_ended_prematurely,
            :name, @name do |y, o|
          _prop = Brazen_::Lib_::Bsc_[].minimal_property o.name
          y << "request ended prematurely - expecting value for #{ par _prop }"
        end
      end

      # ~ displaying the prompt

      def prompt
        if value_is_known
          prompt_when_value
        else
          prompt_when_no_value
        end
      end

      def prompt_when_value  #:+public-API
        @serr.write "new #{ noun } (nothing to cancel): "
        PROCEDE_
      end

      def prompt_when_no_value
        @serr.write "#{ noun } (nothing to cancel): "
        PROCEDE_
      end

      public def noun
        s = self.class::NOUN___
        s || "'#{ @name.as_human }' value"
      end

      NOUN___ = nil

      # ~ blocking for & processing the response

      def receive_mutable_input_line line
        @line = line
        @line.chomp!
        if @line.length.zero?
          when_entered_zero_length_string
        else
          when_entered_nonzero_length_string
        end
      end

      def when_entered_zero_length_string
        when_cancelled
      end

      def when_entered_nonzero_length_string
        if BLANK_RX__ =~ @line
          when_entered_nonzero_length_blank_string
        else
          when_entered_string_with_content
        end
      end

      BLANK_RX__ = /\A[[:space:]]*\z/

      def when_entered_nonzero_length_blank_string
        # it's tempting to make this a "delete" but also kinda nasty -
        # such behavior should be opt-in, lest it is produced accidentally
        when_cancelled
      end

      def when_cancelled
        @y << "edit #{ slug } cancelled."
        change_focus_to @parent
        ACHIEVED_
      end

      def when_deleted  # :+#courtesy
        ok = unknow_value
        if ok
          @y << "deleted #{ slug } value"
          when_value_changed
        else
          @y << "cannot delete #{ slug } value"
          PROCEDE_
        end
      end

      def when_entered_string_with_content
        ok = via_line_know_value
        if ok
          when_value_changed
        else
          PROCEDE_
        end
      end

      def when_value_changed
        if @is_interactive
          try_to_persist  # for now we procede whether or not it succeeds
          change_focus_to @parent
          ACHEIVED_
        end
      end

      # ~ persistence stuff for leaf nodes

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
          @group.activate name_i
        elsif @is_activated
          receive_activation
        else
          receive_deactivation
        end
      end

      def receive_iambic_stream _
        if @group
          @group.activate name_i
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
          Callback_.pair.new :yes, name_i
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
        scn = Callback_.scan.via_times @times
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
          PROCEDE_
        end
      end

      def prompt
      end

      def to_marshal_pair
      end
    end

    ACHEIVED_ = true  # #todo this will be the virgin voyage of [#bs-016]
    FINISHED_ = nil
    NONE_S = '(none)'.freeze
    NOTHING_TO_DO_ = nil

    Zerk_ = self
  end
end
