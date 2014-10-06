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
          resolve_terminal_channel_i
          begin_iambic
          @exception.respond_to?( :members ) and add_members_to_iambic
          resolve_message_proc
          produce_event
        end

        def resolve_terminal_channel_i
          @terminal_channel_i ||= infer_terminal_channel_i ; nil
        end

        def infer_terminal_channel_i
          s_a = @exception.class.name.split Callback_.const_sep
          sub_slice = s_a[ -3, 2 ]
          sub_slice ||= s_a
          s_a_ = sub_slice.map { |s| s.sub TRAILING_UNDERSCORES_RX__, EMPTY_S_ }
          s_a_.join( UNDERSCORE_ ).downcase.intern
        end
        TRAILING_UNDERSCORES_RX__ = /_+\z/

        def begin_iambic
          @iambic = [ @terminal_channel_i, :exception, @exception, :ok, false ] ; nil
        end

        def add_membrs_to_iambic
          @exception.members.each do |i|
            @iambic.push i, @exception.send( i )
          end ; nil
        end

        def resolve_message_proc
          if @do_path_hack
            resolve_message_proc_when_path_hack
          else
            resolve_message_proc_when_no_path_hack
          end
        end

        def resolve_message_proc_when_path_hack
          s = @exception.message
          @path_hack_md = HACK_RX__.match s
          if @path_hack_md
            resolve_message_proc_when_path_hack_md
          else
            resolve_message_proc_when_no_path_hack_md
          end
        end

        def resolve_message_proc_when_path_hack_md
          md = @path_hack_md
          @iambic.push :message_head, md.pre_match
          @iambic.push :rb_function_name, md[ :rb_function_name ].intern
          @iambic.push :pathname, ::Pathname.new( md.post_match )
          @message_proc = -> y, o do
            y << "#{ o.message_head } - #{ pth o.pathname }"
          end ; nil
        end

        def resolve_message_proc_when_no_path_hack_md
          @message_proc = -> y, o do
            y << "« #{ o.terminal_channel_i.id2name.gsub UNDERSCORE_, SPACE_ } »"  # :+#guillemets
          end ; nil
        end

        HACK_RX__ = / @ rb_(?<rb_function_name>[_a-z]+) - /

        def resolve_message_proc_when_no_path_hack
          @message_proc = -> y, o do
            y << o.exception.message
          end ; nil
        end

        def produce_event
          build_event_via_iambic_and_message_proc @iambic, @message_proc
        end
      end
    end
  end
end
