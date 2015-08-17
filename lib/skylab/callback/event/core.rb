module Skylab::Callback

    class Event  # see [#011]

      class << self

        alias_method :construct, :new

        def codifying_expression_agent_instance
          Event_::Models_::Expression_Agent::INSTANCE
        end

        def data_event_class_maker
          Event_::Makers_::Data_Event
        end

        def hooks
          Event_::Makers_::Hooks
        end

        def inline_via_mutable_box_and_terminal_channel_symbol bx, sym, & msg_p
          construct do
            __init_via_box_and_terminal_channel_symbol bx, sym, & ( msg_p || Inferred_Message.to_proc )
          end
        end

        def inline_neutral_with * x_a, & p
          x_a.push :ok, nil
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_not_OK_with * x_a, & p
          inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
        end

        def inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, false
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_neutral_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, nil
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_OK_via_mutable_iambic_and_message_proc x_a, p
          x_a.push :ok, true
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_OK_with * x_a, & p
          x_a.push :ok, true
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
          p ||= Inferred_Message.to_proc
          inline_via_iambic_and_message_proc x_a, p
        end

        def inline_with * x_a, &p
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, p
        end

        def inline_via_normal_extended_mutable_channel x_a  # #experiment with "buildless" events
          top_channel_symbol = x_a.first
          case top_channel_symbol
          when  :error, :info
            if x_a.length.even?
              x_a[ 0, 1 ] = EMPTY_A_
            else
              x_a[ 0 ] = x_a[ 1 ]
            end
            case top_channel_symbol
            when :error
              x_a.push :ok, false
            when :info
              x_a.push :ok, nil
            end
            inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, nil
          end
        end

        def inline_via_iambic x_a, & msg_p
          inline_via_iambic_and_any_message_proc_to_be_defaulted x_a, msg_p
        end

        def inline_via_iambic_and_message_proc x_a, msg_p
          construct do
            __init_via_iambic x_a, & msg_p
          end
        end

        def message_class_maker
          # (hand-written stowaway:)
          Event_::Makers_.const_get :Data_Event
          Event_::Makers_::Message
        end

        def produce_handle_event_selectively_through_methods
          PRODUCE_HANDLE_EVENT_SELECTIVELY_THROUGH_METHODS__
        end

        def prototype_with * x_a, & p
          p ||= Inferred_Message.to_proc
          Event_::Makers_::Prototype.via_deflist_and_message_proc x_a, p
        end

        def prototype
          Event_::Makers_::Prototype
        end

        def selective_builder_sender_receiver x
          x.include Selective_Builder_Receiver_Sender_Methods ; nil
        end

        def structured_expressive
          Event_::Makers_::Structured_Expressive
        end

        def wrap
          WRAP__
        end

        private :new  # #note-045

      end  # >>

      def initialize & p
        instance_exec( & p )
      end

    private

      def __init_via_iambic x_a, & msg_p
        st = Home_::Polymorphic_Stream.via_array x_a
        @terminal_channel_i = st.gets_one
        _process_pairs st.flush_to_each_pairer, & msg_p
        NIL_
      end

      def __init_via_box_and_terminal_channel_symbol bx, sym, & msg_p
        @terminal_channel_i = sym
        _process_pairs bx, & msg_p
      end

      def _process_pairs pairs, & msg_p
        bx = Home_::Box.new
        sc = singleton_class

        pairs.each_pair do | k, x |
          ivar = :"@#{ k }"
          bx.add k, ivar
          instance_variable_set ivar, x
          sc.send :attr_reader, k
        end

        @__ivar_box__ = bx
        @message_proc = msg_p

        NIL_
      end

    public

      def terminal_channel_symbol
        terminal_channel_i
      end

      attr_reader :message_proc, :terminal_channel_i

      def verb_lexeme
      end

      def to_event
        self  # the top
      end

      def with_message_string_mapper p

        _p = Event_::Actors_::
          Produce_new_message_proc_via_map_reducer_and_old_message_proc.call(
            p, message_proc )

        new_with( & _p )
      end

      def new_with * x_a, & msg_p  # #note-25
        dup.init_copy_via_iambic_and_message_proc_ x_a, msg_p
      end

      def new_inline_with * x_a, & msg_p

        bx = __to_mutable_box

        x_a.each_slice 2 do | k, x |
          bx.set k, x
        end

        self.class.inline_via_mutable_box_and_terminal_channel_symbol(
          bx,
          terminal_channel_i,
          & ( msg_p || message_proc ) )
      end

      def to_exception  # #note-85
        Event_::Unwrappers__::Exception[ self ]
      end

      def to_iambic
        box = ivar_box
        a = box.a_ ; h = box.h_
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

      def __to_mutable_box  # just "tags", no terminal channel
        bx = Home_::Box.new
        ivar_box.each_pair do | k, ivar |
          bx.add k, instance_variable_get( ivar )
        end
        bx
      end

    protected

      def init_copy_via_iambic_and_message_proc_ x_a, p  # #note-70

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
      end

    public

      def has_member sym
        formal_properties.has_name sym
      end

      def first_member
        formal_properties.first_name
      end

      def members  # :+[#061]
        formal_properties.get_names
      end

    private
      def ivar_box
        @__ivar_box__
      end

      def formal_properties
        @__ivar_box__
      end
    public

      def description
        s_a = []
        _y = ::Enumerator::Yielder.new do |s|
          s_a.push "(#{ s })"
        end
        express_into_under _y, Event_.codifying_expression_agent_instance
        "(#{ s_a * ', ' })"
      end

      def render_each_line_under expag
        express_into_under(
          ::Enumerator::Yielder.new do | s |
            yield s
          end, expag )
      end

      def express_into_under y, expression_agent
        render_into_yielder_N_lines_under y, nil, expression_agent
      end

      def render_first_line_under expression_agent
        render_into_yielder_N_lines_under( [], 1, expression_agent ).first
      end

      def render_into_yielder_N_lines_under y, d, expag

        N_Lines.new_via_four( y, d, [ message_proc ], expag ).execute self
      end

      def to_stream_of_lines_rendered_under expag  # :+[#064] imagine threads
        s_a = []
        y = ::Enumerator::Yielder.new do |s|
          s_a.push s
        end
        expag.calculate y, self, & message_proc
        Home_::Stream.via_nonsparse_array s_a
      end

      class N_Lines < ::Enumerator::Yielder

        class << self

          def [] * a
            _call_via_arglist a
          end

          def call * a
            _call_via_arglist a
          end

          def _call_via_arglist a
            new( * a ).execute
          end

          alias_method :new_via_four, :new
          private :new
        end  # >>

        def initialize y, n, p_a, expag

          @do_first_line = true
          @expag = expag
          @p_a = p_a
          @y = y

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

          super() do | line |
            @y << line
            tick_p[] or throw :__done_with_N_lines__
            NIL_
          end
        end

        def execute( * a )

          if @do_first_line

            catch :__done_with_N_lines__ do

              @p_a.each do | p |

                p ||= Inferred_Message.to_proc

                @expag.calculate self, * a, & p
              end
            end
          end

          @y
        end
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

        Home_::Actor[ self, :properties,
          :y,
          :expression_agent,
          :o ]

        def execute

          @sp_as_s_a = @o.terminal_channel_i.to_s.split UNDERSCORE_

          maybe_replace_noun_phrase_with_prop
          rslv_item_x_from_first_tag

          if @has_first_tag

            did = maybe_describe_item_x
            did ||= maybe_pathify_item_x
            did || ickify_item_x
            @y << "#{ @sp_as_s_a * SPACE_ } - #{ @item_x }"

          else
            @y << "#{ @sp_as_s_a * SPACE_ }"
          end

          NIL_
        end

      private

        def maybe_replace_noun_phrase_with_prop
          if @o.has_member( :prop ) and find_verb_index
            o = @o
            _pretty = @expression_agent.calculate do
              par o.prop
            end
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
          i = @o.first_member
          if i && :ok != i  # ick
            @has_first_tag = true
            @first_tag_i = i
            @item_x = @o.send @first_tag_i
          else
            @has_first_tag = false
          end ; nil
        end

        def maybe_describe_item_x
          ok = UNABLE_
          if @item_x.respond_to? :description_under
            s = @item_x.description_under @expression_agent
            if s
              @item_x = s
              ok = ACHIEVED_
            end
          end
          if ! ok and @item_x.respond_to? :description
            s = @item_x.description
            if s
              @item_x = s
              ok = ACHIEVED_
            end
          end
          ok
        end

        def maybe_pathify_item_x
          if PN_RX__ =~ @first_tag_i.to_s
            x = @item_x
            @item_x = if x
              @expression_agent.calculate do
                pth x
              end
            end
            ACHIEVED_
          end
        end

        def ickify_item_x
          x = @item_x
          s = @expression_agent.calculate do
            ick x
          end
          @item_x = s ; nil
        end

        PN_RX__ = /(?:_|\A)path(?:name)?\z/
      end

      module Selective_Builder_Receiver_Sender_Methods

      private

        # ~  event building

        def build_not_OK_event_with * x_a, & p
          build_not_OK_event_via_mutable_iambic_and_message_proc x_a, p
        end

        def build_neutral_event_with * x_a, & p
          x_a.push :ok, nil
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

      private

        def normal_top_channel_via_OK_value x
          if x
            :success
          elsif x.nil?
            :info
          else
            :error
          end
        end

        def _OK_value_via_top_channel i
          case i
          when :error
            UNABLE_
          when :info, :payload, :success  # for now we include info
            ACHIEVED_
          end
        end

        # ~ event sending

        def maybe_send_event * i_a, & ev_p
          handle_event_selectively_via_channel.call i_a, & ev_p
        end

        def maybe_send_event_via_channel i_a, & ev_p
          handle_event_selectively_via_channel.call i_a, & ev_p
        end

      public  # ~ event receiving

        def receive_possible_event_via_channel i_a, & ev_p
          handle_event_selectively_via_channel.call i_a, & ev_p
        end

        def handle_event_selectively
          @on_event_selectively ||= __produce_handle_event_selectively_proc
        end

        def handle_event_selectively_via_channel
          @handle_event_selectively_via_channel_proc ||= produce_handle_event_selectively_via_channel
        end

      private

        def __produce_handle_event_selectively_proc
          if handle_event_selectively_via_channel
            -> * i_a, & ev_p do
              @handle_event_selectively_via_channel_proc.call i_a, & ev_p
            end
          end
        end

        def produce_handle_event_selectively_via_channel  # :+#public-API (#hook-in)
          if @on_event_selectively
            -> i_a, & ev_p do
              @on_event_selectively[ * i_a, & ev_p ]
            end
          end
        end

        # ~ common & courtesy

        def change_selective_listener_via_channel_proc x
          @on_event_selectively = nil
          @handle_event_selectively_via_channel_proc = x ; nil
        end

        def accept_selective_listener_proc oes_p
          @on_event_selectively = oes_p ; nil
        end

        def accept_selective_listener_via_channel_proc hesvc_p
          @handle_event_selectively_via_channel_proc = hesvc_p ; nil
        end
      end

      class PRODUCE_HANDLE_EVENT_SELECTIVELY_THROUGH_METHODS__  # :[#006]. (see also [#013])

        class << self

          def bookends * a, & oes_p
            Bookends__.new( a, & oes_p ).produce_selective_listener_proc
          end

          def full * a, & oes_p
            Full__.new( a, & oes_p ).produce_selective_listener_proc
          end
        end

        def initialize a, & oes_p
          @delegate, @channel_i = a
          @fallback_selective_listener_proc = oes_p
        end

        def produce_selective_listener_proc

          -> * i_a, & ev_p do

            m_i = build_longer_method_name_via_channel i_a

            if @delegate.respond_to? m_i or ! @fallback_selective_listener_proc
              @delegate.send m_i, i_a, & ev_p
            else
              @fallback_selective_listener_proc[ * i_a, & ev_p ]
            end
          end
        end

        class Bookends__ < self

          def build_longer_method_name_via_channel i_a
            :"on_#{ @channel_i }_#{ i_a.last }_via_channel"
          end
        end

        class Full__ < self

          def build_longer_method_name_via_channel i_a
            :"on_#{ [ @channel_i, * i_a ] * UNDERSCORE_ }_via_channel"
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
              Event_::Wrappers__::Exception.call_via_iambic x_a
            end
          end

          def file_utils_message s
            Event_::Wrappers__::File_utils_message[ s ]
          end

          def members
            [ :exception, :signature ]
          end

          def signature * a
            Event_::Wrappers__::Signature.call_via_arglist a
          end
        end
      end

      Event_ = self
    end
end
