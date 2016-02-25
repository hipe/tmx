module Skylab::Callback

  class Event
    # -
      class Via_exception < Home_::Actor::Dyadic

        Home_::Actor.methodic self, :properties,
          :exception,
          :terminal_channel_i

        def initialize & p
          @_event_property_pairs = nil
          @_mutator_p_a = nil
          instance_exec( & p )
        end

      private

        def path_hack=  # :[#052].

          _add_mutator do |o|

            md = PATH_HACK_RX___.match o.message

            if md
              o.push :message_head, md.pre_match
              o.push :rb_function_name, md[ :rb_function_name ].intern
              o.push :path, md.post_match
              o.message_proc = -> y, ev do
                y << "#{ ev.message_head } - #{ pth ev.path }"
              end

            else

              o.message_proc = __build_terse_message_proc
            end
          end
        end

        PATH_HACK_RX___ = / @ rb_(?<rb_function_name>[_a-z]+) - /

        def event_property=

          st = polymorphic_upstream
          _sym = st.gets_one
          _x = st.gets_one
          a = ( @_event_property_pairs ||= [] )
          a.push _sym, _x
          KEEP_PARSING_
        end

        def search_and_replace_hack=

          rx = gets_one_polymorphic_value
          p = gets_one_polymorphic_value

          _add_mutator do | o |

            prev_proc = o.message_proc

            o.message_proc = -> y, ev do

              _y_ = ::Enumerator::Yielder.new do | s |

                s.gsub! rx do
                  calculate ev, & p
                end

                y << s
              end

              calculate _y_, ev, & prev_proc
            end
          end
        end

      public

        def _add_mutator & p
          ( @_mutator_p_a ||= [] ).push p
          KEEP_PARSING_
        end

        def execute

          @terminal_channel_i ||= __infer_terminal_channel_symbol

          __begin_edit

          if @exception.respond_to? :members
            __via_exception_add_members_to_edit
          end

          if @_event_property_pairs
            @_sess.concat @_event_property_pairs
            @_event_property_pairs = nil
          end

          if @_mutator_p_a
            @_mutator_p_a.each do | p |
              p[ @_sess ]
            end
          end

          __flush
        end

        def __infer_terminal_channel_symbol

          # the exception class's name is transformed to a terminal channel
          # name by using the trailing two or one consts of the exception
          # class's name parts like so:
          #
          #     ::Foo::Bar_::Baz_Exception__ => :bar_baz_exception

          s_a = @exception.class.name.split Home_.const_sep

          sub_slice = s_a[ -2, 2 ]

          sub_slice ||= s_a

          s_a_ = sub_slice.map do |s|
            s.sub TRAILING_UNDERSCORES_RX___, EMPTY_S_
          end

          s_a_.join( UNDERSCORE_ ).downcase.intern
        end

        TRAILING_UNDERSCORES_RX___ = /_+\z/

        def __begin_edit

          o = Session___.new @terminal_channel_i, @exception
          o.push :exception, @exception, :ok, false
          o.message_proc = UNMAPPED_MESSAGE_PROC___
          @_sess = o
          NIL_
        end

        UNMAPPED_MESSAGE_PROC___ = -> y, o do
          y << o.exception.message
        end

        def __via_exception_add_members_to_edit

          @exception.members.each do |sym|

            @_sess.push sym, @exception.send( sym )
          end
          NIL_
        end

        def __build_terse_message_proc

          -> y, o do

            _s = o.terminal_channel_i.id2name.gsub UNDERSCORE_, SPACE_

            y << "« #{ _s  } »"  # :+#guillemets
          end
        end

        def __flush

          _x_a, _p = @_sess.flush

          Home_::Event.
            inline_via_iambic_and_any_message_proc_to_be_defaulted _x_a, _p
        end

        class Session___

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
    # -
  end
end
