module Skylab::Brazen

  module Entity

    class Event__  # see [#011]

      class << self

        alias_method :construct, :new

        def build_not_OK_event_via_mutable_iambic_and_msg_proc x_a, p
          x_a.push :ok, false
          p ||= Inferred_Message.to_proc
          inline_via_iambic_and_message_proc x_a, p
        end

        def codifying_expression_agent
          Event_::EXPRESSION_AGENT__
        end

        def inline_with * x_a, &p
          p ||= Inferred_Message.to_proc
          inline_via_iambic_and_message_proc x_a, p
        end

        def inline_via_iambic_and_message_proc x_a, p
          construct do
            init_via_x_a_and_p x_a, p
          end
        end

        def prototype_with * x_a, & p
          Event_::Prototype__.via_deflist_and_message_proc x_a, p
        end

        def prototype
          Event_::Prototype__
        end

        def receiver & p
          if p
            Receiver__::Proc_Adapter__.new p
          else
            Receiver__
          end
        end

        def sender x
          x.include Sender_Methods__ ; nil
        end

        def wrap
          WRAP__
        end

        private :new  # #note-045

      end # >>

      def initialize & p
        instance_exec( & p )
      end

    private def init_via_x_a_and_p x_a, p
        @message_proc = p
        scn = Lib_::Iambic_scanner[].new 0, x_a
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

      def verb_lexeme
      end

      def to_event
        self  # the top
      end

      def with_message_string_mapper p
        dup_with( & Event_::Small_Time_Actors__::
          Produce_new_message_proc_from_map_reducer_and_old_message_proc[
            p, message_proc ] )
      end

      def dup_with * x_a, & p  # #note-25
        dup.init_copy_via_iambic_and_message_proc x_a, p
      end

      def to_exception  # #note-85
        Event_::Unwrappers__::Exception[ self ]
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

    protected( def init_copy_via_iambic_and_message_proc x_a, p  # #note-70
        bx = ivar_box
        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set bx.fetch( i ), x
        end
        sc = singleton_class
        bx.each_name do |i|
          sc.send :attr_reader, i
        end
        p and @message_proc = p
        self
      end )

      def has_tag i
        reflection_box.has_name i
      end

      def first_tag_name
        reflection_box.first_name
      end

      def members  # :+[#061]
        get_tag_names
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

      def description
        s_a = []
        _y = ::Enumerator::Yielder.new do |s|
          s_a.push "(#{ s })"
        end
        render_all_lines_into_under _y, Event_::EXPRESSION_AGENT__
        "(#{ s_a * ', ' })"
      end

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

      def scan_for_render_lines_under expag
        # with threads we could do this one line at a time but meh
        s_a = []
        y = ::Enumerator::Yielder.new do |s|
          s_a.push s
        end
        expag.calculate y, self, & @message_proc
        Callback_.scan.via_nonsparse_array s_a
      end

      class Inferred_Message  # #experimental - you hate me now

        class << self
          def to_proc  # a message proc
            _CLS_ = self
            -> y, o do
              _CLS_[ y, self, o ] ; nil
            end
          end
        end

        Callback_::Actor[ self, :properties,
          :y,
          :expression_agent,
          :o ]

        def execute
          @sp_as_s_a = @o.terminal_channel_i.to_s.split UNDERSCORE_
          maybe_replace_noun_phrase_with_prop
          rslv_item_x_from_first_tag
          did = maybe_describe_item_x
          did ||= maybe_pathify_item_x
          did || ickify_item_x
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
        VERB_RX__ = /\A(?:already|cannot|does|has|is)\z/  # etc as needed

        def rslv_item_x_from_first_tag
          @first_tag_i = @o.first_tag_name
          @item_x = @o.send @first_tag_i ; nil
        end

        def maybe_describe_item_x
          ok = UNABLE_
          if @item_x.respond_to? :description_under
            s = @item_x.description_under @expression_agent
            if s
              @item_x = s
              ok = ACHEIVED_
            end
          end
          if ! ok and @item_x.respond_to? :description
            s = @item_x.description
            if s
              @item_x = s
              ok = ACHEIVED_
            end
          end
          ok
        end

        def maybe_pathify_item_x
          if PN_RX__ =~ @first_tag_i.to_s
            x = @item_x
            s = @expression_agent.calculate do
              pth x
            end
            @item_x = s
            ACHEIVED_
          end
        end

        def ickify_item_x
          x = @item_x
          s = @expression_agent.calculate do
            ick x
          end
          @item_x = s ; nil
        end

        PN_RX__ = /(?:_|\A)pathname\z/
      end

      module Sender_Methods__
      private

        def send_not_OK_event_with * x_a, & p
          _ev = build_not_OK_event_via_mutable_iambic_and_message_proc x_a, p
          _ev_ = wrap_event _ev
          send_event _ev_
        end

        def send_neutral_event_with * x_a, & p
          _ev = build_event_via_iambic_and_message_proc x_a, p
          _ev_ = wrap_event _ev
          send_event _ev_
        end

        def send_OK_event_with * x_a, & p
          _ev = build_OK_event_via_mutable_iambic_and_message_proc x_a, p
          _ev_ = wrap_event _ev
          send_event _ev_
        end

        def wrap_event ev
          ev
        end

        def build_not_OK_event_with * x_a, & p
          build_not_OK_event_via_mutable_iambic_and_message_proc x_a, p
        end

        def build_neutral_event_with * x_a, & p
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_OK_event_with * x_a, & p
          build_OK_event_via_mutable_iambic_and_message_proc x_a, p
        end

        def build_not_OK_event_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, false
          build_event_via_iambic_and_message_proc x_a, p
        end

        def build_OK_event_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, true
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

        def make_event_prototype_with * deflist, & p
          Event_.prototype.via_deflist_and_message_proc deflist, p
        end

        def event_class
          Event_
        end

        def send_event ev
          event_receiver.receive_event ev
        end

        def event_receiver
          @event_receiver
        end

        def _Event
          Event_
        end
      end

      module Receiver__

        class << self

          def channeled * a
            if a.length.zero?
              Channeled__
            else
              Channeled__.new a
            end
          end

          def via_proc p
            Proc_Adapter__.new p
          end

          def map_reduce evr, & p
            Map_Reduce__.new p, evr
          end
        end

        class Proc_Adapter__
          def initialize p
            @p = p
          end
          def receive_event ev
            @p[ ev ]
          end
        end

        class Map_Reduce__
          def initialize p, evr
            @evr = evr ; @p = p
          end
          def receive_event ev
            ev_ = @p[ ev ]
            ev_ and @evr.receive_event ev_
          end
        end

        class Channeled__

          class << self
            def full * a
              if a.length.zero?
                Full__
              else
                Full__.new a
              end
            end
          end

          def initialize a
            @channel_i, @delegate = a
            @m_i = build_channeled_event_meth_i
          end

          attr_reader :channel_i, :delegate  # hax

          def receive_event ev
            @delegate.send @m_i, ev
          end

        private

          def build_channeled_event_meth_i
            :"receive_#{ @channel_i }_event"
          end

          class Full__ < self

            class << self
              def cascading * a
                Cascading__.new a
              end
            end

            def initialize a
              @channel_i, @delegate = a
            end

            def receive_event ev
              _m_i = build_longest_meth_i_for_ev ev
              @delegate.send _m_i, ev
            end
          private

            def build_longest_meth_i_for_ev ev
              :"receive_#{ @channel_i }_#{ ev.terminal_channel_i }"
            end

            class Cascading__ < self
              def receive_event ev
                m_i = build_longest_meth_i_for_ev ev
                if @delegate.respond_to? m_i
                  @delegate.send m_i, ev
                else
                  _m_i = build_channeled_event_meth_i
                  @delegate.send _m_i, ev
                end
              end
            end
          end
        end
      end

      module WRAP__

        class << self

          def exception *x_a
            if x_a.length.zero?
              Event_::Wrappers__::Exception
            else
              # implement an :+[#cb-057] ideal mixed syntax
              x_a[ 0, 0 ] = [ :exception ]
              Event_::Wrappers__::Exception.via_iambic x_a
            end
          end

          def file_utils_message s
            Event_::Wrappers__::File_utils_message[ s ]
          end

          def members
            [ :exception, :signature ]
          end

          def signature * a
            Event_::Wrappers__::Signature.via_arglist a
          end
        end
      end

      Event_ = self
    end
  end
end
