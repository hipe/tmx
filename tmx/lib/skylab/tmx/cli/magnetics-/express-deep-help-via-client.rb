module Skylab::TMX

  class CLI

    class Magnetics_::ExpressDeepHelp_via_Client < Common_::Monadic  # 1x

      # you love it

        def initialize cli
          @CLI = cli
          @filesystem = ::Dir
          @line_downstream = cli.stderr
          @_omni = cli.current_argument_parsing_idioms
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

          scn = Common_::Scanner.via_array _items

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

          gss = Basic_[]::Tree::Magnetics::TextGlyph_via_NodeCategory::GlyphSets
          gs = gss::WIDE    # or
          gs = gss::NARROW  # or

          @_blank = gs.fetch :blank
          @_crook = gs.fetch :crook
          @_pipe = gs.fetch :pipe
          @_tee = gs.fetch :tee
        end

        def __synopsis_lines_via_one_off one_off

          _lines = @__syno.synopsis_lines_by do |downstream|

            one_off.express_help_by do |o|
              o.downstream = downstream
              o.program_name_head_string_array = @CLI.program_name_string_array
            end

            # (don't bother checking exitstatus - it does the throw hack for early exit)
          end

          _lines
        end

        def __init_synopsiser

          @__syno = Zerk_lib_[]::CLI::SynopsisLines_via_HelpScreen.define do |o|
            o.number_of_synopsis_lines = 3
          end

          NIL
        end

        def __to_sidesystems_of_interest_scanner

          scn = @_omni.features.TO_FLATTENED_QUALIFIED_FEATURE_SCANNER do |o|
            o.strict_injector_symbol_pass_filter = {
              tmx_primaries: false,
              tmx_intrinsic: false,
              tmx_mountable_sidesystem: true,
              tmx_mountable_one_off: false,
              # zerk_one_off_category_symbol: false,
             #  zerk_sidesystem_loadable_reference_category_symbol: true
            }
          end

          p = -> do
            # hand-written map-reduce for clarity
            until scn.no_unparsed_exists

              qfeat = scn.gets_one
              _sidesys = qfeat.value
              sub_scn = _sidesys.to_one_off_scanner_via_filesystem @filesystem

              if sub_scn.no_unparsed_exists
                # if no one-offs under the operator
                next
              end
              x = Sidesystem___.new sub_scn, qfeat
              break
            end
            x
          end

          ::NoDependenciesZerk::Scanner_by.new do
            p[]
          end
        end
      # -

      # ==

      class Sidesystem___

        def initialize sub_scn, qfeat
          @qualified_feature = qfeat
          @sub_scanner = sub_scn
        end

        def slug
          @qualified_feature.value.slug
        end

        attr_reader(
          :qualified_feature,
          :sub_scanner,
        )
      end

      # ==
    end
  end
end
# #born of a dream
