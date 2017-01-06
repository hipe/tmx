module Skylab::TMX

  class CLI

    When_ = ::Module.new
    WhenSupport_ = ::Module.new

    class When_::Help < Common_::Actor::Monadic

      # this node has two arguably separate responsibilities: one is to
      # lead to the expression of help screens generally (for local and
      # remote operators alike); and two is what we explain here. maybe
      # one day the particular will apply to the general..

      # tmx has special needs that making parsing around help .. special:

      # both as an exercise and because it's what we want, we effect the
      # parsing of "verboses" alongside the (now complete) parsing of the
      # help switch against a particular set of design objectives, of which
      # there are surprisingly many needed to make this behave unsurprisingly:
      #
      #   - distinctive of [tmx], the presence of a verbose modifiers
      #     alters expression of help.
      #
      #   - perhaps unique to [tmx], the *number* of verboses has semantic
      #     importance with regard to how help is expressed. (there are
      #     discrete tiers, and the number of supported tiers will change
      #     over development time.)
      #
      #   - with the exceptions that following this point, it must be the
      #     case that the expression of help is executed even when a full
      #     argument scan would otherwise fail to parse because: often we
      #     come asking for help when we have some primary parse error,
      #     and it's convenient to be able to leave the offending tokens in
      #     the request when asking for help so that the request can be
      #     corrected semi-interactively. (but we (for now) grant ourselves
      #     the requirement that the help switch come *before* any offending
      #     tokens, because left-to-right serial processing is a fundamental
      #     mechanic governing not just this but all argument parsing.)
      #
      #   - so in effect the only primaries we care about processing are
      #     verbose flags, and for our own parsimony we will only parse
      #     those any contiguous switches that immediately follow the
      #     (already parsed) help token. (like all tokens that came before,
      #     verboses that came before are OK too.)
      #
      #   - if it were the case that a token might mean "verbose" but might
      #     mean something else ("version", say) we want the user to know
      #     about this ambiguity (unrecoverable as they always are), so we
      #     whine and fail under such case..
      #
      #   - to be good citizens we will retreat the scanner over a primary
      #     we will not consume (even though we are probably at the last
      #     stop of the application anyway).

      def initialize o
        @args = o.args
        @omni = o.omni
        @CLI = o
      end

      def execute
        if __is_root
          if __parse_arguments
            _money
          end
        else
          _money
        end
      end

      def __is_root
        1 == @CLI.selection_stack.length
      end

      def _money

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

      # ==

      def __program_name
        Program_name_via_client_[ @CLI ]
      end

      def __items
        items = @_didactics.to_item_normal_tuple_stream
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

        top = @CLI.selection_stack.last

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
        @_didactics = @CLI.selection_stack.last.to_didactics  # buckle up
        NIL
      end

      def __stderr
        @CLI.stderr
      end

      # == [ze] #nodeps-Coverpoint-5 was created to cover this.

      def __parse_arguments

        # generally, parse the zero or more contiguous tokens immediately
        # following the ~"-h" token that look like verboses. perhaps only
        # these cases can cause it to fail:
        #
        #   - ambiguity of ~"-v" with some other primary
        #     (actually any ambiguity at this point)
        #   - too many verboses (because verifying expected semantics is important)

        begin
          if __argument_scanner_is_empty
            _show_help_screen
            break
          end
          if ! __parse_primary_softly
            _show_help_screen
            break
          end
          __lookup_primary
          if __lookup_was_ambiguous
            break
          end
          if ! __primary_was_found
            _retreat_one
            _show_help_screen
            break
          end
          if ! __found_primary_was_verbose
            _retreat_one
            _show_help_screen
            break
          end
          if __verbose_limit_is_reached
            __whine_about_too_many_verbose
            break
          end
          redo
        end while above

        remove_instance_variable :@_ok
      end

      def __argument_scanner_is_empty
        @args.no_unparsed_exists
      end

      def __parse_primary_softly
        @args.parse_primary_softly
      end

      def __lookup_primary
        @_lookup = @omni.lookup_current_primary_symbol_semi_softly
        NIL
      end

      def __lookup_was_ambiguous
        did = @_lookup.had_unrecoverable_error_which_was_expressed
        did && @_ok = false
        did
      end

      def __primary_was_found
        @_lookup.was_found
      end

      def __found_primary_was_verbose
        :verbose == @_lookup.primary_symbol
      end

      def __verbose_limit_is_reached
        # (the semantics are a little broken here..)
        lu = remove_instance_variable :@_lookup
        inj = @omni.primary_injectors.fetch lu.injector_offset
        inj.object_id == @CLI.object_id || fail  # it's OK if it's not
        _ok = inj.send lu.injector_method_name
        ! _ok
      end

      def __whine_about_too_many_verbose
        @_ok = false
        NOTHING_ # (did)
      end

      def _retreat_one
        @args.retreat_one
        NIL
      end

      def _show_help_screen
        @_ok = true ; nil
      end

      # ==

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
