module Skylab::TMX

  class CLI

    When_ = ::Module.new
    WhenSupport_ = ::Module.new

    class When_::Help < Common_::Actor::Monadic

      def initialize o
        @client = o
      end

      def execute

        __resolve_is_multimode
        __resolve_didactics

        __help_screen_module.express_into __stderr do |o|

          o.item_normal_tuple_stream __items

          o.express_usage_section __program_name

          o.express_description_section __description_proc

          o.express_items_sections __description_reader
        end

        # (result of above is NIL only b.c that's the result of the last stmt)

        NIL  # EARLY_END
      end

      def __program_name
        Program_name_via_client_[ @client ]
      end

      def __items

        items = @_didactics.item_normal_tuple_stream_by[]
        if @_is_multimode
          items = @_arg_scn.altered_normal_tuple_stream_via items
        end
        items
      end

      def __description_reader
        rdr = @_didactics.description_proc_reader
        if @_is_multimode
          rdr = @_arg_scn.altered_description_proc_reader_via rdr
        end
        rdr
      end

      def __resolve_is_multimode

        # is_root = 1 == @client.selection_stack.length

        top = @client.selection_stack.last

        as = top.argument_scanner

        if as.respond_to? :add_primary_at_position
          @_is_multimode = true
          @_arg_scn = as
          HELP_RX =~ as.head_as_is || self._PARSING_MODEL
          as.advance_one
        else
          @_is_multimode = false
        end
        NIL
      end

      def __help_screen_module
        _const = @_didactics.is_branchy ? :ScreenForBranch : :ScreenForEndpoint
        _mod = Zerk_lib_[]::NonInteractiveCLI::Help
        _mod.const_get _const, false
      end

      def __description_proc
        @_didactics.description_proc
      end

      def __resolve_didactics
        @_didactics = @client.selection_stack.last.to_didactics  # buckle up
        NIL
      end

      def __stderr
        @client.stderr
      end

      include WhenSupport_
    end

  if false
  class Models_::Reactive_Model_Dispatcher

    Events_ = ::Module.new

    cls = Common_::Event.prototype_with(

      :missing_first_argument,
      :unbound_stream_builder, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do | y, o |

      st = o.unbound_stream_builder[]
      o = st.gets
      if o
        y << "missing first argument."
      else
        y << "there are no reactive nodes."
      end
    end

    def cls.[] guy
      super(
        guy.unbound_stream_builder,
      )
    end

    Events_::Missing_First_Argument = cls

    cls = Common_::Event.prototype_with(

      :no_such_reactive_node,
      :argument_x, nil,
      :unbound_stream_builder, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do | y, o |

      y << "unrecognized argument #{ ick o.argument_x }"

      st = o.unbound_stream_builder[]
      o = st.gets
      if o

        p = -> unbound do
          unbound.description_under self
        end

        s_a = [ p[ o ] ]
        o_ = st.gets
        if o_
          o__ = st.gets
          if o__
            s_a.push ', ', p[ o_ ], ', etc.'
          else
            s_a.push ' or ', p[ o_ ]
          end
        end
        y << "expecting #{ s_a.join }"
      else
        y << "there are no reactive nodes."
      end
    end

    def cls.[] guy
      super(
        guy.first_argument,
        guy.unbound_stream_builder,
      )
    end

    Events_::No_Such_Reactive_Node = cls
  end
  end  # if false

    module WhenSupport_

      # ==

      name_stream_via_selection_stack = nil

      Program_name_via_client_ = -> client do

        buffer = client.get_program_name
        st = name_stream_via_selection_stack[ client.selection_stack ]
        begin
          nm = st.gets
          nm || break
          buffer << SPACE_ << nm.as_slug
          redo
        end while nil
        buffer
      end

      name_stream_via_selection_stack = -> ss do
        Common_::Stream.via_range( 1  ... ss.length ).map_by do |d|
          ss.fetch( d ).name
        end
      end

      # ==
    end  # WhenSupport___

    Events_ = ::Module.new  # meh
    Events_::MountRelated = ::Module.new
  end  # CLI
end
