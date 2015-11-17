module Skylab::SubTree

  class Models_::File_Coverage

    Modalities = ::Module.new

    module Modalities::CLI

      STYLE_FOR_ASSET_ONLY__ = [ :red ]
      STYLE_FOR_TEST_ONLY__ = [ :cyan ]
      STYLE_FOR_ASSET_AND_TEST___ = [ :green ]

      # ~

      Actions = ::Module.new  # THE_EMPTY_MODULE_

      class Actions::File_Coverage < Home_::CLI::Action_Adapter

        def init_properties  # #nascent-operation :+[#br-042]

          bp = @bound.formal_properties
          fp = bp.to_mutable_box_like_proxy

          fp.replace_by :path do | prp |

            prp.dup.prepend_ad_hoc_normalizer do | qkn, & oes_p |

              path = ( qkn.value_x if qkn.is_known_known )

              if path && ::File::SEPARATOR != path[ 0 ]

                Callback_::Known_Known[ ::File.expand_pat path ]
              else
                qkn.to_knownness
              end
            end
          end

          @back_properties = bp
          @front_properties = fp
          NIL_
        end
      end

      class Agnostic_Text_Based_Expression

        def initialize * a
          @y, @expag, @tree = a
        end

        def execute

          st = @tree.to_classified_stream_for :text,
            :glyphset_identifier_x,
            @expag.file_coverage_glyphset_identifier__

          st.gets  # root node is never interesting

          begin

            cx = st.gets
            cx or break

            __express_one_line_for cx

            redo
          end while nil

          ACHIEVED_
        end

        def __express_one_line_for cx

          @y << "#{ cx.prefix_string }#{ __styled_string_for cx.node }"  # prefix_string can be nil
          NIL_
        end

        def __styled_string_for node

          npl = node.node_payload
          if npl
            if npl.has_assets
              if npl.has_tests
                __say_node_with_both node
              else
                __say_node_with_assets node
              end
            elsif npl.has_tests
              __say_node_with_tests node
            else
              node.slug
            end
          else
            node.slug
          end
        end

        def __say_node_with_both node

          npl = node.node_payload

          _s = "( #{ _say_asset_entries npl } <-> #{
                     _say_test_entries npl } )"

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

        def _say_asset_entries npl

          [ * npl.asset_dir_entry_s_a, * npl.asset_file_entry_s_a ] * COMMA___
        end

        def _say_test_entries npl

          [ * npl.test_dir_entry_s_a, * npl.test_file_entry_s_a ] * COMMA___
        end

        COMMA___ = ', '
      end
    end
  end
end

# :#tombstone: :+[#bs-001] post-assembly-language-phase-phase
