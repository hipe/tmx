module Skylab::TMX

  class CLI

    class Magnetics_::ExpressDeepHelp_via_Client < Common_::Actor::Monadic  # 1x

      # you love it

        def initialize cli
          @CLI = cli
          @filesystem = ::Dir
          @line_downstream = cli.stderr
          @omni = cli.omni
        end

        def execute
          scn = __to_sidesystems_of_interest_scanner
          if scn.no_unparsed_exists
            @CLI.stderr.puts "(nothing)"
          else
            __when_some scn
          end
        end

        def __when_some scn

          __init_glyphs
          __init_synopsiser
          serr = @line_downstream
          buffer = ""
          begin
            ss = scn.gets_one
            if scn.no_unparsed_exists
              stop = true
            end
            buffer << ( stop ? @_crook : @_tee )
            buffer << ss.slug
            serr.puts buffer
            if stop
              __descend_final_one ss.sub_scanner
              break
            end
            __descend_nonfinal_one ss.sub_scanner
            buffer.clear
            redo
          end while above

          NIL
        end

        def __descend_final_one x
          _descend_one @_blank, x
        end

        def __descend_nonfinal_one x
          _descend_one @_pipe, x
        end

        def _descend_one head, sub_scn

          @_sub_head_for_nonfinal_line = "#{ head }#{ @_tee }"

          begin
            one_off = sub_scn.gets_one
            if sub_scn.no_unparsed_exists
              stop = true
            end
            __express_lines_for_sub_item stop, head, one_off
            stop && break
            redo
          end while above
          NIL
        end

        def __express_lines_for_sub_item is_final, head, one_off

          slug = one_off.slug

          _items = __synopsis_lines_via_one_off one_off

          scn = Common_::Polymorphic_Stream.via_array _items

          if is_final
            my_final_head = "#{ head }#{ @_crook }"
          else
            my_final_head = "#{ head }#{ @_tee }"
          end
          if scn.no_unparsed_exists
            self._NEVER
            @line_downstream.puts "#{ my_final_head }#{ slug }"
          else
            desc = scn.gets_one
            if scn.no_unparsed_exists
              @line_downstream.puts "#{ my_final_head }#{ slug } - #{ desc }"
            else
              @line_downstream.puts "#{ my_final_head }#{ slug } - #{ desc }"
              if is_final
                extra_line_margin = "#{ head }#{ @_blank }#{ SPACE_ }"
              else
                extra_line_margin = "#{ head }#{ @_pipe }#{ SPACE_ }"
              end
              begin
                desc = scn.gets_one
                @line_downstream.puts "#{ extra_line_margin } #{ desc }"
              end until scn.no_unparsed_exists
            end
          end
          NIL
        end

        def __init_glyphs

          gss = Basic_[]::Tree.unicode::GlyphSets
          gs = gss::WIDE    # or
          gs = gss::NARROW  # or

          @_blank = gs.fetch :blank
          @_crook = gs.fetch :crook
          @_pipe = gs.fetch :pipe
          @_tee = gs.fetch :tee
        end

        def __synopsis_lines_via_one_off one_off

          const = one_off.sub_top_level_const_guess
          if ! @_mod.const_defined? const, false
            load one_off.path
          end

          _proc_like = @_mod.const_get const, false

          _pnsa = [ * @CLI.program_name_string_array, *
            one_off.program_name_tail_string_array ]

          _argv = HELP_ARGV___.dup  # those that use optparse consume

          _lines = @__syno.synopsis_lines_by do |serr|

            _proc_like[ _argv, DUMMY_STDIN___, :_no_sout_tmx_, serr, _pnsa ]

            # (don't bother checking exitstatus - it does the throw hack for early exit)

          end

          _lines
        end

        def __init_synopsiser

          @__syno = Zerk_lib_[]::CLI::SynopsisLines_via_HelpScreen.define do |o|
            o.number_of_synopsis_lines = 3
          end

          @_mod = One_off_branch_module___[]
          NIL
        end

        def __to_sidesystems_of_interest_scanner

          scn = @omni.to_operator_load_ticket_scanner
          scn.advance_one while ::Symbol === scn.current_token  # horrible

          Common_::Stream.via_scanner( scn ).map_reduce_by do |lt|

            sub_scn = lt.to_one_off_scanner_via_filesystem @filesystem

            unless sub_scn.no_unparsed_exists
              Sidesystem___.new sub_scn, lt
            end
          end.flush_to_polymorphic_stream
        end
      # -

      # ==

      class Sidesystem___

        def initialize sub_scn, lt
          @load_ticket = lt
          @sub_scanner = sub_scn
        end

        def slug
          @load_ticket.slug
        end

        attr_reader(
          :load_ticket,
          :sub_scanner
        )
      end

      # ==

      One_off_branch_module___ = Lazy_.call do
        module ::Skylab__Zerk__OneOffs
          # while #nascent [#ze-063.1]
          self
        end
      end

      # ==

      module DUMMY_STDIN___ ; class << self
        def tty?
          false
        end
      end ; end

      # ==

      HELP_ARGV___ = %w( --help ).freeze

      # ==
    end
  end
end
# #born of a dream
