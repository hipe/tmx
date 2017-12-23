# frozen_string_literal: true

module Skylab::GitViz

  # [#006] is the CLI client narrative

  class Models_::HistTree

    Modalities = ::Module.new

    module Modalities::CLI

      module Actions

        class HistTree < Home_.lib_.brazen::CLI::Action_Adapter

          GLYPHS___ =
            # "\u2058",  # Four Dot Punctuation - ⁘
            "\u29bf",  # Circled Bullet - ⦿
            # ~
            # "\u25c9",  # Fisheye - ◉
            "\u25cf",  # Blank Circle - ●
            "\u2022",  # Bullet - ●
            "\u2b24"   # Blank Large Circle - ⬤

          def init_properties  # #nascent-operation :+[#br-042]

            super

            fp = mutable_front_properties
            rsx = @resources

            # ~ f

            fs = rsx.bridge_for :filesystem
            substitute_value_for_argument :filesystem do
              fs
            end

            # ~ p

            edit_path_properties :path, :absolutize_relative_path

            # ~ s

            io = rsx.serr
            substitute_value_for_argument :stderr do
              io
            end

            sys = rsx.bridge_for :system_conduit
            substitute_value_for_argument :system_conduit do
              sys
            end

            # ~ v

            substitute_value_for_argument :VCS_adapter_name do
              :git
            end

            # ~ w

            _any_prp_class = fp.at_offset( 0 ).class

            _prp = _any_prp_class.new_by do

              @name = Common_::Name.via_variegated_symbol :width
              @parameter_arity = :one

              add_normalizer_for_greater_than_or_equal_to_integer 1
            end

            fp.add_to_front :width, _prp

            NIL_
          end

          def prepare_backstream_call x_a

            # :+[#br-049] hacks like these are temporary.
            # this is a :+#frontier for a front-only prop with validation

            sym = x_a.fetch 0

            _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol(
              x_a.fetch( 1 ), sym
            )

            bx = @front_properties.fetch( sym ).ad_hoc_normalizer_box

            _p = bx.h_.fetch( bx.a_.first )

            qkn = _p.call _qkn do | * i_a, & ev_p |

              receive_event_on_channel ev_p[], i_a
            end

            x_a[ 0, 2 ] = EMPTY_A_

            qkn and begin
              @width = qkn.value
              ACHIEVED_
            end
          end

          def bound_call_via_bound_call_from_back bc  # frontier experiment of :+[#br-060]

            @bound_call_from_back = bc

            Common_::BoundCall.via_receiver_and_method_name self, :__render
          end

          def __render

            ok = __via_bound_call_from_back_resolve_bundle
            ok &&= __via_bundle_resolve_sparse_matrix_of_content
            ok &&= __via_sparse_matrix_of_content_resolve_business_column
            ok && __via_business_column_render
          end

          def __via_bound_call_from_back_resolve_bundle

            bc = @bound_call_from_back
            ht = bc.receiver.send bc.method_name, * bc.args
            ht and begin
              @bundle = ht.bundle
              @repo = ht.repo
              ACHIEVED_
            end
          end

          def __via_bundle_resolve_sparse_matrix_of_content

            table = Home_::Magnetics_::SparseMatrix_of_Content_via_Bundles.call(
              @bundle, @repo )

            table and begin
              @matrix = table
              ACHIEVED_
            end
          end

          def __via_sparse_matrix_of_content_resolve_business_column

            st = Home_.lib_.basic::Tree.via(
              :node_identifiers,
              @matrix.rows,

            ).to_classified_stream_for :text

            st.gets  # the first node is always the root node,
              # which never has any visual representation

            max = 0
            biz_column_strings = []
            viz_column_rows = []

            begin
              o = st.gets
              o or break
              node, prefix_string = o.to_a
              s = "#{ prefix_string }#{ node.slug }"
              biz_column_strings.push s

              if node.is_leaf

                viz_column_rows.push node.node_payload

                d = s.length  # or include the branch nodes. it's a design choice
                if max < d
                  max = d
                end
              else
                viz_column_rows.push nil
              end
              redo
            end while nil

            @business_column_strings = biz_column_strings
            @business_column_max_width = max
            @viz_column_rows = viz_column_rows

            ACHIEVED_
          end

          def __via_business_column_render

            lib = Home_.lib_.brazen_NOUVEAU::RasterMagnetics

            _glypherer = lib::Glypher_via_Glyphs_and_Stats.start( * GLYPHS___ )

            lib::ScaledTimeLineItemStream_via_Glypher.call_by(

              text_downstream: @resources.sout,

              viz_column_rows: @viz_column_rows,

              business_column_max_width: @business_column_max_width,
              business_column_strings: @business_column_strings,

              width: @width,
              glypherer: _glypherer,
              column_order: COLUMN_ORDER___,
            )
          end
        end
      end

      # ==

      COLUMN_ORDER___ = %i( biz_column viz_column ).freeze

      # ==
      # ==
    end
  end
end
# :+#tombstone:  o.base.long[ 'use-mocks' ] = ::OptionParser::Switch::NoArgument.new do  # :+#hidden-option
# (keep this line for posterity - there was some AMAZING foolishness going
# on circa early '12 that is a good use case for why autoloader (for [#ca-024])
