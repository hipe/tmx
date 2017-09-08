module Skylab::TMX

  class CLI

    When_ = ::Module.new
    WhenSupport_ = ::Module.new

    class When_::Help < Common_::Monadic

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
      #   - (this note is somewhat redundant with a long note in the test)
      #
      #   - distinctive of a tmx is that the presence of verbose modifiers
      #     alters the particular help expression behavior.
      #
      #   - perhaps unique to a tmx, the *number* of verboses has semantic
      #     importance with regard to how help is expressed. (there are
      #     discrete tiers, and the number of supported tiers will change
      #     over development time.)
      #
      #   - with the exceptions that follow this point, it must be the
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
        @_omni = o.current_argument_parsing_idioms
        @argument_scanner_narrator = @_omni.argument_scanner_narrator
        @CLI = o
      end

      def execute
        @_is_root = __is_root
        if @_is_root
          if no_unparsed_exists
            _money
          elsif match_primary_shaped_token
            if __parse_primaries
              _money
            end
          elsif
            __drop_back
          end
        else
          _money
        end
      end

      def __is_root
        1 == @CLI.selection_stack.length
      end

      def __drop_back
        @CLI.do_dispatch_help_ = true
        NOTHING_  # we want KEEP_PARSING_ but we need early exit to get out of the nodeps primary parsing
      end

      def _money  # express some kind of help screen

        # because a tree-like help screen is fundamentally different
        # structurally, detect that that's what we're doing early..

        if 1 < @CLI.verbose_count_
          if @_is_root
            CLI::Magnetics_::ExpressDeepHelp_via_Client[ @CLI ]
          else
            @CLI.stderr.puts "(deep help is only for root for now)"  # meh
            UNABLE_
          end
        else
          __express_a_classic_help_screen
        end
      end

      def __express_a_classic_help_screen

        __init_is_multimode
        __init_didactics

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

      def __init_is_multimode

        top = @CLI.selection_stack.last

        as = top.argument_scanner_narrator

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

      def __init_didactics
        @_didactics = @CLI.selection_stack.last.to_didactics  # buckle up
        NIL
      end

      def __stderr
        @CLI.stderr
      end

      # == [ze] #Coverpoint1.5 was created to cover this.
      #         see that test file for an in-depth, comprehensive explanation

      def __parse_primaries

        begin

          if ! look_up_primary_via_match

            if ! primary_was_ambiguous_or_similar
              _show_help_screen
            end
            break
          end

          if ! __found_primary_was_verbose
            _show_help_screen
            break
          end

          if __verbose_limit_reached
            break
          end

          if no_unparsed_exists
            _show_help_screen
            break
          end

          if ! match_primary_shaped_token
            self._COVER_ME__say_something_about_going_to_ignore_this_term__
            _show_help_screen
            break
          end

          redo
        end while above

        remove_instance_variable :@_ok
      end

      def primary_was_ambiguous_or_similar
        yes = super
        if yes
          @_ok = false
        end
        yes
      end

      def __found_primary_was_verbose
        @_primary_found = release_primary_found
        :verbose == @_primary_found.primary_match.primary_symbol
      end

      def __verbose_limit_reached

        # this is a copy-paste of bespoke test case: [ze] #Coverpoint1.1

        found = remove_instance_variable :@_primary_found
        injr = @_omni.features.injector_via_primary_found found
        injr.object_id == @CLI.object_id || fail
        ok = injr.send found.trueish_feature_value
        if ok
          @argument_scanner_narrator.advance_past_match found.primary_match
          false
        else
          @_ok = false
          true
        end
      end

      def _show_help_screen
        @_ok = true ; nil
      end

      # ==

      include Interface_::NarratorMethods
      include WhenSupport_
    end

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
  end  # CLI
end
