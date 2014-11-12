module Skylab::Brazen

  module Zerk  # see [#062]

    class Common_Agent

      # :+#hook-out's: (methods you need to implement in your child class)
      #
      #   `to_body_item_value_string` - false-ish means do not display

      def initialize x
        @name ||= self.class.name_function
        @sin = x.sin
        @serr = x.serr
        @parent = x
        @y = x.primary_UI_yielder
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
      RX__ = /\A.+(?=_(?:Agent|Boolean|Button|Field)_*\z)/  # :+#experimental
    end

    public

      # ~ resources & metadata that parent will ask of you as a child

      def name_i
        @name.as_variegated_symbol
      end

      def slug
        @name.as_slug
      end

      def is_executable
        true
      end

      def execute
        ok = display_panel
        ok && block_for_response
      end

      def exitstautus
        0
      end

    private

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

    public

      # ~ resources, metadata & methods that children will ask of you as parent

      attr_reader :parent, :sin, :serr

      def primary_UI_yielder
        @y
      end

      def is_agent
        true
      end

      def change_focus_to x
        @parent.change_focus_to x
      end
    end

    class Branch_Agent < Common_Agent
    private

      def receive_mutable_input_line s
        s.strip!
        rx = /\A#{ ::Regexp.escape s }/i
        cx_a = []
        @children.each do |cx|
          cx.is_executable or next
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
        @y << "did you mean #{ cx_a.map( & :slug ) * ' or ' } ?"
        AS_IS_
      end

      def when_none s
        @y << "unrecognized command: #{ s.inspect }"
        @y << "please enter #{ build_prompt_line }"
        AS_IS_
      end

      def when_one cx
        @parent.change_focus_to cx
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
        AS_IS_
      end

      def build_prompt_line  # #note-190
        a = []
        @children.each do |cx|
          cx.is_executable or next
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

      def build_child_hashtable  # :+#courtesy
        h = {}
        @children.each do |cx|
          h[ cx.name_i ] = cx
        end
        h
      end

      def [] name_i  # :+#courtesy
        @children.detect do |cx|
          name_i == cx.name_i
        end
      end

    private

      # ~ persistence stuff for branch node

      def retrieve_values_from_FS_if_exist  # :+#courtesy
        Zerk_::Actors__::Retrieve[
          @persist_path, @children, method( :maybe_receive_persist_event ) ]
      end

      def maybe_receive_persist_event i, *_, & ev_p
        send_event ev_p[]
      end
    end

    class Leaf_Agent < Common_Agent

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
        AS_IS_
      end

      def prompt_when_no_value
        @serr.write "#{ noun } (nothing to cancel): "
        AS_IS_
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
      end

      def when_deleted  # :+#courtesy
        ok = unknow_value
        if ok
          @y << "deleted #{ slug } value"
          when_value_changed
        else
          @y << "cannot delete #{ slug } value"
          AS_IS_
        end
      end

      def when_entered_string_with_content
        ok = via_line_know_value
        if ok
          when_value_changed
        else
          AS_IS_
        end
      end

      def when_value_changed
        try_to_persist  # for now we procede whether or not it succeeds
        change_focus_to @parent
      end

      # ~ persistence stuff for leaf nodes

      def try_to_persist
        @parent.receive_try_to_persist
      end
    end

    class Persistence_Actor_
    private
      def receive_persistence_error ev
        @on_event_selectively.call :error do
          ev
        end ; nil
      end

      def line_scan_for_event ev
        _expag = Brazen_::API.expression_agent_instance
        ev.scan_for_render_lines_under _expag
      end
    end

    RECEIVE_TRY_TO_PERSIST_METHOD = -> do
      Zerk_::Actors__::Persist.with(
        :path, @persist_path,
        :children, @children,
        :serr, @serr,
        :on_event_selectively, method( :maybe_receive_persist_event ) )
    end

    AS_IS_ = :as_is_signal
    AS_IS_SIGNAL = AS_IS_
    ACHEIVED_ = true  # #todo this will be the virgin voyage of [#bs-016]
    NONE_S = '(none)'.freeze
    NOTHING_TO_DO_ = nil

    Zerk_ = self
  end
end
