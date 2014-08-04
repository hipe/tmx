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
        @ivar_box.get_local_normal_names
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

      module Simple_Listener_Broadcaster___

        def self.[] mod
          mod.include self ; nil
        end

      private

        def entity_event * x_a, & p
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
