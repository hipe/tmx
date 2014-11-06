module Skylab::Brazen

  module Zerk  # see [#062]

    class Common_Agent_

      # :+#hook-out's; (methods you need to implement in your child class)
      #
      #   `to_body_item_value_string` - false-ish means do not display

      def initialize x
        @name ||= infer_name
        @sin = x.sin
        @serr = x.serr
        @parent = x
        @y = x.primary_UI_yielder
      end
    private
      def infer_name
        _const = Callback_::Name.via_module( self.class ).as_const
        _cnst = RX__.match( _const )[ 0 ]
        Callback_::Name.via_const _cnst
      end
      RX__ = /\A.+(?=_Agent_*\z)/
    public

      # ~ resources & metadata that parent will ask of you as a child

      def name_i
        @name.as_variegated_symbol
      end

      def slug
        @name.as_slug
      end

      def before_UI
        # will get called every time before this nodes gets "focus"
        @did_prepare_for_UI ||= prepare_for_UI
        nil
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

      def prepare_for_UI
        ACHEIVED_
      end

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

    public

      # ~ resources, metadata & methods that children will ask of you as parent

      attr_reader :parent, :sin, :serr

      def primary_UI_yielder
        @y
      end

      def is_agent
        true
      end

      def change_agent_to x
        @parent.change_agent_to x
      end
    end

    class Branch_Agent < Common_Agent_
    private

      def block_for_response
        s = @sin.gets
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
        STAY_
      end

      def when_none s
        @y << "unrecognized command: #{ s.inspect }"
        @y << "please enter #{ build_prompt_line }"
        STAY_
      end

      def when_one cx
        cx.before_UI
        @parent.change_agent_to cx
        STAY_
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
        STAY_
      end

      def build_prompt_line
        # #todo this is not yet done in the smart way
        s_a = []
        @children.each do |cx|
          cx.is_executable or next
          first, rest = cx.slug.split RX__
          s_a.push "[#{ first }]#{ rest }"
        end
        s_a * SPACE_
      end
      RX__ = /(?<=\A.)/

    public

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

    class Leaf_Agent < Common_Agent_

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
      #                       like [#cb-055] pair. justification at #note-022.
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
        STAY_
      end

      def prompt_when_no_value
        @serr.write "#{ noun } (nothing to cancel): "
        STAY_
      end

      def noun
        self.class.const_get :NOUN___
      end

      NOUN___ = 'value'

      # ~ blocking for & processing the response

      def block_for_response
        @line = @sin.gets
        when_entered
      end

      def when_entered
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
        change_agent_to @parent
      end

      def when_deleted  # :+#courtesy
        ok = unknow_value
        if ok
          @y << "deleted #{ slug } value"
          when_value_changed
        else
          @y << "cannot delete #{ slug } value"
          STAY_
        end
      end

      def when_entered_string_with_content
        ok = via_line_know_value
        if ok
          when_value_changed
        else
          STAY_
        end
      end

      def when_value_changed
        try_to_persist  # for now we procede whether or not it succeeds
        change_agent_to @parent
      end

      # ~ persistence stuff for leaf nodes

      def try_to_persist
        @parent.receive_try_to_persist
      end

      public def to_pair_for_persist
        x = marshal_dump
        if ! x.nil?
          Callback_.pair.new x, name_i
        end
      end
    end

    class Persistence_Actor_
    private
      def write_event_to_serr ev
        scan = line_scan_for_event ev
        while line = scan.gets
          @serr.puts line
        end
        nil
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

    ACHEIVED_ = true  # #todo this will be the virgin voyage of [#bs-016]
    NONE_S = '(none)'.freeze
    NOTHING_TO_DO_ = nil
    STAY_ = true
    Zerk_ = self
  end
end
