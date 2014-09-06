module Skylab::Brazen

  module Entity

    class Event  # see [#011]

      class << self

        alias_method :construct, :new

        def inline_via_iambic_and_message_proc x_a, p
          construct do
            init_via_x_a_and_p x_a, p
          end
        end

        def prototype_via_iambic_and_message_proc x_a, p
          Event::Prototype__.via_iambic_and_message_proc x_a, p
        end

        def wrap_universal_exception e
          Event::Wrappers__::Universal_exception[ e ]
        end

        private :new  # not implemented
      end

      def initialize & p
        instance_exec( & p )
      end

    private def init_via_x_a_and_p x_a, p
        @message_proc = p
        scn = Iambic_Scanner.new 0, x_a
        @terminal_channel_i = scn.gets_one
        box = Box_.new
        sc = singleton_class
        while scn.unparsed_exists
          i = scn.gets_one
          ivar = :"@#{ i }"
          box.add i, ivar
          instance_variable_set ivar, scn.gets_one
          sc.send :attr_reader, i
        end
        @__ivar_box__ = box ; nil
      end

      attr_reader :message_proc, :terminal_channel_i

      def dup_with * x_a  # #note-25
        dup.init_copy_with x_a
      end

      def to_iambic
        box = ivar_box
        a = box.send :a ; h = box.send :h
        y = ::Array.new 1 + a.length * 2
        y[ 0 ] = terminal_channel_i
        d = -1 ; last = a.length - 1
        while d < last
          d += 1
          y[ d * 2 + 1 ] = a.fetch d
          y[ d * 2 + 2 ] = instance_variable_get h.fetch a.fetch d
        end
        y
      end

    protected( def init_copy_with x_a  # #note-70
        bx = ivar_box
        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set bx.fetch( i ), x
        end
        sc = singleton_class
        bx.each_name do |i|
          sc.send :attr_reader, i
        end
        self
      end )

      def to_event
        self  # the top
      end

      def has_tag i
        reflection_box.has_name i
      end

      def first_tag_name
        reflection_box.first_name
      end

      def tag_names
        get_tag_names
      end

      def get_tag_names
        reflection_box.get_names
      end

    private
      def ivar_box
        @__ivar_box__
      end

      def reflection_box
        @__ivar_box__
      end
    public

      def render_all_lines_into_under y, expression_agent
        render_into_yielder_N_lines_under y, nil, expression_agent
      end

      def render_first_line_under expression_agent
        render_into_yielder_N_lines_under( [], 1, expression_agent ).first
      end

      def render_into_yielder_N_lines_under y, d, expag
        N_Lines.new( y, d, [ message_proc ], expag ).execute self
      end

      class N_Lines < ::Enumerator::Yielder

        def initialize y, n, p_a, expag
          @do_first_line = true ; @expag = expag ; @p_a = p_a ; @y = y
          if n
            if 1 > n
              @do_first_line = false
            else
              d = 0
              tick_p = -> { n != ( d += 1 ) }
            end
          else
            tick_p = NILADIC_TRUTH_
          end
          super() do |line|
            @y << line
            tick_p[] or throw :__done_with_N_lines__ ; nil
          end
        end
        def execute( * a )
          if @do_first_line
            catch :__done_with_N_lines__ do
              @p_a.each do |p|
                p ||= Inferred_Message.to_proc
                @expag.calculate self, * a, & p
              end
            end
          end
          @y
        end
      end

      class Inferred_Message  # #experimental - you hate me now

        define_singleton_method :to_proc, -> do
          cls = self
          -> y, o do
            cls.new( y, self, o ).execute ; nil
          end
        end

        def initialize y, expag, o
          @expression_agent = expag ; @o = o ; @y = y ; nil
        end

        def execute
          @sp_as_s_a = @o.terminal_channel_i.to_s.split UNDERSCORE_
          maybe_replace_noun_phrase_with_prop
          rslv_item_x_from_first_tag
          did = maybe_pathify_item_x
          did || maybe_clarity_item_x
          @y << "#{ @sp_as_s_a * SPACE_ } - #{ @item_x }" ; nil
        end

      private

        def maybe_replace_noun_phrase_with_prop
          if @o.has_tag( :prop ) and find_verb_index
            _pretty = @expression_agent.par @o.prop
            @sp_as_s_a[ 0, @verb_index ] = [ _pretty ]
          end ; nil
        end

        def find_verb_index
          @verb_index = @sp_as_s_a.length.times.detect do |d|
            VERB_RX__ =~ @sp_as_s_a[ d ]
          end
        end
        VERB_RX__ = /\A(?:already|does|is)\z/  # etc as needed

        def rslv_item_x_from_first_tag
          @first_tag_i = @o.first_tag_name
          @item_x = @o.send @first_tag_i ; nil
        end

        def maybe_pathify_item_x
          if PN_RX__ =~ @first_tag_i.to_s
            @item_x = @expression_agent.pth @item_x
            true
          end
        end

        def maybe_clarity_item_x
          if @item_x.nil?
            @item_x = "''" ; nil
          end
        end

        PN_RX__ = /(?:_|\A)pathname\z/
      end

      module Builder_Methods
      private

        def build_error_event_with * x_a, & p
          build_error_event_via_mutable_iambic_and_message_proc x_a, p
        end

        def build_success_event_with * x_a, & p
          build_success_event_via_mutable_iambic_and_message_proc x_a, p
        end

        def build_error_event_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, false
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_success_event_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, true
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_event_with * x_a, & p
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_event_via_iambic x_a, & p
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_event_via_iambic_and_message_proc x_a, p
          p.nil? and p = default_event_message_proc_value
          event_class.inline_via_iambic_and_message_proc x_a, p
        end

        def default_event_message_proc_value
          Inferred_Message.to_proc
        end

        def build_event_prototype_with * x_a, & p
          Event.prototype_via_iambic_and_message_proc x_a, p
        end

        def event_class
          Event
        end
      end

      module Base_Sender_Methods__
      private
        def send_event_with * x_a, & p
          send_event_structure build_event_via_iambic_and_message_proc( x_a, p )
        end
        def send_structure_on_channel ev, chan_i
          send_structure_on_channel_to_listener ev, chan_i, listener
        end
        def send_structure_on_channel_to_listener ev, chan_i, listener
          send_structure_with_method_to_listener ev,
            :"receive_#{ chan_i }_#{ ev.terminal_channel_i }", listener
        end
        def send_structure_with_method ev, m_i
          send_structure_with_method_to_listener ev, m_i, listener
        end
        def send_structure_with_method_to_listener ev, m_i, listener
          listener.send m_i, ev
        end
      end

      module Cascading_Prefixing_Sender

        def self.[] mod
          mod.include Base_Sender_Methods__
          mod.send :define_method, :send_event_structure, P__ ; nil
        end

        P__ = -> ev do
          @channel or self._NO_CHANNEL
          m_i = :"receive_#{ @channel }_#{ ev.terminal_channel_i }"
          if @listener.respond_to? m_i
            send_structure_with_method ev, m_i
          else
            @listener.send :"receive_#{ @channel }_event", ev
          end
        end
      end

      module Merciless_Prefixing_Sender

        def self.[] mod
          mod.include Base_Sender_Methods__
          mod.send :define_method, :send_event_structure, P__ ; nil
        end

        P__ = -> ev do
          @channel or self._NO_CHANNEL
          send_structure_on_channel ev, @channel
        end
      end
    end
  end
end
