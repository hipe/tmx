module Skylab::Brazen

  module Entity

    class Event__

      class Wrappers__::Exception

        Entity[ self, -> do

          def path_hack  # :[#052].
            @do_path_hack = true
          end

          o :properties,
            :exception,
            :terminal_channel_i

        end ]

        Event__.sender self

        def initialize & p
          @do_path_hack = false
          instance_exec( & p )
        end

        def execute
          @terminal_channel_i ||= infer_terminal_channel_i
          @iambic = [ @terminal_channel_i, :exception, @exception, :ok, false ]
          e = @exception
          e.respond_to? :members and add_values_to_iambic
          resolve_message_proc
          produce_event
        end

        def infer_terminal_channel_i
          s_a = @exception.class.name.split Callback_.const_sep
          sub_slice = s_a[ -3, 2 ]
          sub_slice ||= s_a
          s_a_ = sub_slice.map { |s| s.sub TRAILING_UNDERSCORES_RX__, EMPTY_S_ }
          s_a_.join( UNDERSCORE_ ).downcase.intern
        end
        TRAILING_UNDERSCORES_RX__ = /_+\z/

        def add_values_to_iambic
          @exception.members.each do |i|
            @iambic.push i, @exception.send( i )
          end ; nil
        end

        def resolve_message_proc
          @message_proc = if @do_path_hack
            message_proc_when_path_hack
          else
            -> y, o do
              y << o.exception.message
            end
          end
        end

        def message_proc_when_path_hack
          -> y, o do
            s = o.exception.message
            md = HACK_RX__.match s
            if md
              y << "#{ md.pre_match } - #{ pth md.post_match }"
            else
              y << "« #{ o.terminal_channel_i.id2name.gsub UNDERSCORE_, SPACE_ } »"  # :+#guillemets
            end
          end
        end
        HACK_RX__ = / @ rb_sysopen - /

        def produce_event
          build_event_via_iambic_and_message_proc @iambic, @message_proc
        end
      end
    end
  end
end
