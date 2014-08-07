module Skylab::Brazen

  module Entity

    class Event

      def initialize x_a, p
        @message_proc = p
        scn = Iambic_Scanner.new 0, x_a
        @terminal_channel_i = scn.gets_one
        @ivar_box = Box_.new
        sc = singleton_class
        while scn.unparsed_exists
          i = scn.gets_one
          ivar = :"@#{ i }"
          @ivar_box.add i, ivar
          instance_variable_set ivar, scn.gets_one
          sc.send :attr_reader, i
        end ; nil
      end

      attr_reader :message_proc, :terminal_channel_i

      def has_tag i
        @ivar_box[ i ]
      end

      def has_member i
        @ivar_box.has_name i
      end

      def first_member
        @ivar_box.first_name
      end

      def members
        @ivar_box.get_names
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

      module Simple_Listener_Broadcaster___

        def self.[] mod
          mod.include self ; nil
        end

      private

        def entity_event * x_a, & p
          p ||= Inferred_Message.to_proc
          broadcast_entity_event Event.new x_a, p
        end

        def broadcast_entity_event ev
          m = :"on_entity_event_channel_#{
            }#{ ev.terminal_channel_i }_entity_structure"
          if @listener.respond_to? m
            @listener.send m, ev
          else
            @listener.on_entity_event_channel_entity_structure ev
          end ; nil
        end
      end
    end
  end
end
