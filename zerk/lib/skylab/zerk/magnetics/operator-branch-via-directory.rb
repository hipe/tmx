module Skylab::Zerk

  class Magnetics::OperatorBranch_via_Directory < Common_::SimpleModelAsMagnetic  # :[#051.G]

    # about the asymmetry of where this stored vs the other [#051]'s:
    #
    # unlike the other #[#051] operator branches, we are putting this
    # one here because despite it's name, really it's more of an adapter
    # for mounted one-offs (for now (but it would be nice if it could be
    # generalized in-place to work for any directories we wanted it to)).
    #
    # so the placement here is an exercise of the design axiom that nodes
    # that adapt between a more general and a more specific facility should
    # be closer to the more specific facility. the bulk of the other operator
    # branch adapters are all siblings with each other because they all
    # relate to more general ideas (hashes, modules). since this (in
    # practice if not in name) relates to the more specific idea of a
    # "one-off", it's housed in location more suited to that concern..

    # ==

    class OA  # ..

      def initialize one_off, cli
        @CLI = cli
        @one_off = one_off
      end

      def to_bound_call_for_help

        _by_this = -> o do
          o.program_name_head_string_array = @CLI.program_name_string_array
          o.downstream = @CLI.stderr
        end

        Common_::BoundCall[ nil, @one_off, :express_help_by, & _by_this ]
      end

      def to_bound_call_for_invocation

        _proc = @one_off.require_proc_like

        _pnsa = [ * @CLI.program_name_string_array,
                  * @one_off.program_name_tail_string_array ]

        _scn = @CLI.release_argument_scanner_for_mounted_operator

        d, argv = _scn.close_and_release
        argv[ 0, d ] = EMPTY_A_

        _args = [ argv, @CLI.stdin, @CLI.stdout, @CLI.stderr, _pnsa ]

        _maybe_one_day = -> do
          ::Kernel._K__readme__  # mmmaaayyybeee some one-offs want resources? but don't
        end

        Common_::BoundCall[ _args, _proc, :call, & _maybe_one_day ]
      end
    end

    # ==

    # -

      def initialize
        yield self
        @glob_entry ||= GLOB_STAR_
        mod = @sidesystem_module
        # ..
          load_ticket = Home_::Models::Sidesystem::LoadTicket_via_AlreadyLoaded[ mod ]
        # ..

        @_scn = Home_::Magnetics_::OneOffScanner_via_LoadTicket.call_by do |o|
          o.load_ticket = load_ticket
          o.filesystem = remove_instance_variable :@filesystem_for_globbing
          o.glob_entry = remove_instance_variable :@glob_entry
        end

        @CACHE = {}
        @_open = true
      end

      attr_writer(
        :glob_entry,
        :filesystem_for_globbing,
        :sidesystem_module,
      )

      # -- read

      def dereference key_x
        lt = lookup_softly key_x
        if lt
          lt
        else
          raise ::KeyError
        end
      end

      def lookup_softly key_x
        x = @CACHE[ key_x.intern ]
        if x
          x
        elsif @_open
          __keep_looking_because_open key_x
        end
      end

      def __keep_looking_because_open key_x

        sym = key_x.intern

        st = _to_remaining_item_stream_DANGEROUS
        begin
          oo = st.gets
          oo || break
          if sym == oo.normal_symbol
            found_oo = oo
            break
          end
          redo
        end while above
        if found_oo
          found_oo
        else
          # hi. #a.s-coverpoint-3
          found_oo
        end
      end

      def to_load_ticket_stream
        if @_open
          if @CACHE.length.zero?
            _to_remaining_item_stream_DANGEROUS
          else
            __to_item_stream_when_open
          end
        else
          _to_item_stream_using_only_cache
        end
      end

      def __to_item_stream_when_open
        self._README__fun__  # #open [#co-016.1] concatted streams refactor
      end

      def _to_remaining_item_stream_DANGEROUS
        scn = @_scn
        p = -> do
          oo = scn.gets_one
          if scn.no_unparsed_exists
            @_open = false
            remove_instance_variable :@_scn
            p = EMPTY_P_
          end
          @CACHE[ oo.normal_symbol ] = oo
          oo
        end
        if scn.no_unparsed_exists
          p = EMPTY_P_
        end
        Common_::MinimalStream.by do
          p[]
        end
      end

      def _to_item_stream_using_only_cache
        Stream_[ @CACHE.values ]
      end
    # -

    # ==

    GLOB_STAR_ = '*'

    # ==
  end
end
# #history: broke out of (now) "one-off" model
