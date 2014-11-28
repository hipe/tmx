module Skylab::Brazen

    class Event__

      class Wrappers__::Exception

        Entity.call self do

          def path_hack  # :[#052].
            add_mutator do |o|
              md = PATH_HACK_RX__.match o.message
              if md
                o.push :message_head, md.pre_match
                o.push :rb_function_name, md[ :rb_function_name ].intern
                o.push :path, md.post_match
                o.message_proc = -> y, ev do
                  y << "#{ ev.message_head } - #{ pth ev.path }"
                end
              else
                o.message_proc = terse_message_proc
              end
            end
          end

          def properties
            @xtra_prop_x_a = flush_remaining_iambic
          end

          def search_and_replace_hack
            rx = iambic_property
            p = iambic_property
            add_mutator do |o|
              prev_proc = o.message_proc
              o.message_proc = -> y, ev do
                _y_ = ::Enumerator::Yielder.new do |s|
                  s.gsub! rx do
                    calculate ev, & p
                  end
                  y << s
                end
                calculate _y_, ev, & prev_proc
              end
            end
          end

          o :properties,
            :exception,
            :terminal_channel_i

        end

        Event__.selective_builder_sender_receiver self

        PATH_HACK_RX__ = / @ rb_(?<rb_function_name>[_a-z]+) - /

        def initialize & p
          @mutator_p_a = nil
          @xtra_prop_x_a = nil
          instance_exec( & p )
        end

        def add_mutator & p
          ( @mutator_p_a ||= [] ).push p ; nil
        end

        def execute
          resolve_terminal_channel_i
          begin_edit
          if @exception.respond_to? :members
            via_exception_add_members_to_edit
          end
          if @xtra_prop_x_a
            @edit.concat @xtra_prop_x_a
            @xtra_prop_x_a = nil
          end
          if @mutator_p_a
            @mutator_p_a.each do |p|
              p[ @edit ]
            end
          end
          flush
        end

        def resolve_terminal_channel_i
          @terminal_channel_i ||= infer_terminal_channel_i ; nil
        end

        def infer_terminal_channel_i

          # the exception class's name is transformed to a terminal channel
          # name by using the trailing two or one consts of the exception
          # class's name parts like so:
          #
          #     ::Foo::Bar_::Baz_Exception__ => :bar_baz_exception

          s_a = @exception.class.name.split Callback_.const_sep
          sub_slice = s_a[ -2, 2 ]
          sub_slice ||= s_a
          s_a_ = sub_slice.map { |s| s.sub TRAILING_UNDERSCORES_RX__, EMPTY_S_ }
          s_a_.join( UNDERSCORE_ ).downcase.intern
        end

        TRAILING_UNDERSCORES_RX__ = /_+\z/

        def begin_edit
          o = Mutable_Edit__.new @terminal_channel_i, @exception
          o.push :exception, @exception, :ok, false
          o.message_proc = UNMAPPED_MESSAGE_PROC__
          @edit = o ; nil
        end

        UNMAPPED_MESSAGE_PROC__ = -> y, o do
          y << o.exception.message
        end

        def via_exception_add_members_to_edit
          @exception.members.each do |i|
            @edit.push i, @exception.send( i )
          end ; nil
        end

        def terse_message_proc
          -> y, o do
            y << "« #{ o.terminal_channel_i.id2name.gsub UNDERSCORE_, SPACE_ } »"  # :+#guillemets
          end ; nil
        end

        def flush
          build_event_via_iambic_and_message_proc( * @edit.flush )
        end

        class Mutable_Edit__

          def initialize tc_i, e
            @x_a = [ tc_i ]
            @msg_p = -> do
              e.message
            end
          end

          def message
            @msg_p.call
          end

          attr_accessor :message_proc

          def push * x_a
            concat x_a
          end

          def concat x_a
            @x_a.concat x_a ; nil
          end

          def flush
            [ @x_a, @message_proc ]
          end
        end
      end
    end
end
