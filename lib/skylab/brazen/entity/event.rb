module Skylab::Brazen

  module Entity

    class Event  # see [#011]

      class << self

        alias_method :construct, :new

        def inline_via_x_a_and_p x_a, p
          construct do
            init_via_x_a_and_p x_a, p
          end
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

    protected( def init_copy_with x_a
        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set ivar_box.fetch( i ), x
        end
        sc = singleton_class
        ivar_box.each_name do |i|
          sc.send :attr_reader, i
        end
        self
      end )

      def to_event
        self  # the top
      end

      def has_tag i
        ivar_box[ i ]
      end

      def has_member i
        ivar_box.has_name i
      end

      def first_member
        ivar_box.first_name
      end

      def members
        ivar_box.get_names
      end

    private def ivar_box
        @__ivar_box__
      end

      def render_all_lines_into_under y, expression_agent
        render_into_yielder_N_lines_under y, nil, expression_agent
      end

      def render_first_line_under expression_agent
        render_into_yielder_N_lines_under( [], 1, expression_agent ).first
      end

      def render_into_yielder_N_lines_under y, d, expag
        N_Lines.new( y, d, [ @message_proc ], expag ).execute self
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
          rslv_item_x_from_first_member
          maybe_pathify_item_x
          @y << "#{ @sp_as_s_a * SPACE_ } - #{ @item_x }" ; nil
        end
      private
        def maybe_replace_noun_phrase_with_prop
          if @o.has_member( :prop ) and find_verb_index
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
        def rslv_item_x_from_first_member
          @first_member_i = @o.first_member
          @item_x = @o.send @first_member_i ; nil
        end
        def maybe_pathify_item_x
          if PN_RX__ =~ @first_member_i.to_s
            @item_x = @expression_agent.pth @item_x
          end ; nil
        end
        PN_RX__ = /(?:_|\A)pathname\z/
      end

      module Cascading_Prefixing_Sender

        def self.[] mod
          mod.include self ; nil
        end

      private

        def send_event * x_a, & p
          p ||= Inferred_Message.to_proc
          _ev = Event.inline_via_x_a_and_p x_a, p
          send_event_structure _ev
        end

        def send_event_structure ev
          @prefix or self._NO_PREFIX
          m_i = :"receive_#{ @prefix }_#{ ev.terminal_channel_i }"
          if @listener.respond_to? m_i
            @listener.send m_i, ev
          else
            @listener.send :"receive_#{ @prefix }_event", ev
          end ; nil
        end
      end

      module Merciless_Prefixing_Sender

        def self.[] mod
          mod.include self ; nil
        end

      private

        def send_event * x_a, & p
          p ||= Inferred_Message.to_proc
          _ev = Event.inline_via_x_a_and_p x_a, p
          send_event_structure _ev
        end

        def send_event_structure ev
          @prefix or self._NO_PREFIX
          _m_i = :"receive_#{ @prefix }_#{ ev.terminal_channel_i }"
          @listener.send _m_i, ev
        end
      end

      class Listener_X

        def initialize listener, cls
          @cls = cls ; @listener = listener
        end

        def sign_event ev
          _verb_s = inflected_verb
          _noun_s = inflected_noun
          Signature_Wrapper__.new _verb_s, _noun_s, ev
        end
      private

        def inflected_verb
          if custom_inflection and verb_s = @custom_inflection.verb
            verb_s
          else
            @cls.name_function.as_human
          end
        end

        def inflected_noun  # #note-210
          if custom_inflection and noun_s = @custom_inflection.noun
            noun_s
          elsif prnt = @cls.name_function.parent
            prnt.name_function.as_human
          elsif @custom_inflection && @custom_inflection.verb
            @cls.name_function.as_human
          end
        end

        def custom_inflection
          @custom_inflection ||= @cls.custom_inflection
        end
      end

      class Signature_Wrapper__
        def initialize verb_s, noun_s, ev
          @ev = ev
          @inflected_noun = noun_s
          @inflected_verb = verb_s
        end
        attr_reader :inflected_noun, :inflected_verb, :ev

        def to_event
          @ev.to_event
        end

        def terminal_channel_i
          @ev.terminal_channel_i
        end

        def render_all_lines_into_under y, expag
          @ev.render_all_lines_into_under y, expag
        end

        def verb_lexeme
          @verb_lexeme ||= Lib_::NLP[]::EN::POS::Verb[ @inflected_verb ]
        end
      end
    end
  end
end
