module Skylab::TestSupport

  module FileCoverage

    module CLI

      # #spot-ts-CLI explains why there is no full CLI exposure here.
      # :#spot-fc-CLI (sorry).

      STYLE_FOR_ASSET_ONLY__ = [ :red ]
      STYLE_FOR_TEST_ONLY__ = [ :cyan ]
      STYLE_FOR_ASSET_AND_TEST___ = [ :green ]

      # ==

      # this is the #frontier of [#ze-046] #mode-tweaking: we map the `path`
      # component association (acting as a parameter) to a new parameter that
      # has prepended to its front a new normalization proc (same thing as
      # component model woah) that turns relative paths into absolute paths
      # using the filesystem.
      #
      # (the backend ACS is not allowed to know the present working directory
      # so it requires that paths be absolute.)

      NODE_MAP = {
        path: -> par, cli_frame do
          par.prepend_normalization_by do |st, & pp|
            path = st.gets_one
            if Path_looks_relative_[ path ]
              path = cli_frame.root_frame.CLI.filesystem.expand_path path
            end
            Common_::KnownKnown[ path ]
          end
        end
        # (we do the above often enough that it is now tracked by #[#ze-048])
      }

      # ==

      class Agnostic_Text_Based_Expression

        def initialize * a
          @y, @expag, @tree = a
        end

        def execute

          _sym = @expag.file_coverage_glyphset_identifier__
          st = @tree.to_classified_stream_for(
            :text,
            :glyphset_identifier_x,
            _sym,
          )

          st.gets  # root node is never interesting

          begin
            cx = st.gets
            cx || break
            __express_one_line_for cx
            redo
          end while nil

          ACHIEVED_
        end

        def __express_one_line_for cx
          _ = __styled_string_for cx.node
          @y << "#{ cx.prefix_string }#{ _ }"  # prefix_string can be nil
          NIL_
        end

        def __styled_string_for node

          pl = node.node_payload
          if pl
            if pl.has_assets
              if pl.has_tests
                __say_node_with_both node
              else
                __say_node_with_assets node
              end
            elsif pl.has_tests
              __say_node_with_tests node
            else
              node.slug
            end
          else
            node.slug
          end
        end

        def __say_node_with_both node

          pl = node.node_payload

          _s = "( #{ _say_asset_entries pl } <-> #{
                     _say_test_entries pl } )"

          @expag.stylify_ STYLE_FOR_ASSET_AND_TEST___, _s
        end

        def __say_node_with_assets node

          @expag.stylify_ STYLE_FOR_ASSET_ONLY__,
            _say_asset_entries( node.node_payload )
        end

        def __say_node_with_tests node

          @expag.stylify_ STYLE_FOR_TEST_ONLY__,
            _say_test_entries( node.node_payload )
        end

        def _say_asset_entries pl

          [ * pl.asset_dir_entry_s_a, * pl.asset_file_entry_s_a ] * COMMA___
        end

        def _say_test_entries pl

          [ * pl.test_dir_entry_s_a, * pl.test_file_entry_s_a ] * COMMA___
        end

        COMMA___ = ', '
      end
    end
  end
end
# #tombstone: pre-zerk, parts of an ancient `rerun` operation, debugging options
# :#tombstone: :+[#bs-001] post-assembly-language-phase-phase
