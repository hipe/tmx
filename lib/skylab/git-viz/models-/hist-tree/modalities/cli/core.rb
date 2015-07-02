module Skylab::GitViz

  # [#006] is the CLI client narrative

  class Models_::HistTree

    Modalities = ::Module.new

    module Modalities::CLI

      module Actions

        class Hist_Tree < Home_.lib_.brazen::CLI::Action_Adapter

          GLYPHS___ =
            # "\u2058",  # Four Dot Punctuation - ⁘
            "\u29bf",  # Circled Bullet - ⦿
            # ~
            # "\u25c9",  # Fisheye - ◉
            "\u25cf",  # Blank Circle - ●
            "\u2022",  # Bullet - ●
            "\u2b24"   # Blank Large Circle - ⬤

          def resolve_properties  # #nascent-operation :+[#br-042]

            bp = @bound.formal_properties.to_mutable_box_like_proxy

            bp.replace_by :path do | prp |

              prp.dup.append_ad_hoc_normalizer do | arg, & oes_p |

                # hackd for now

                path = arg.value_x

                if ! path.respond_to?( :relative_path_from ) && ::File::SEPARATOR != path[ 0 ]
                  arg = arg.new_with_value ::File.expand_path path
                end
                arg
              end
            end

            # ~

            fp = bp.dup
            @bound.change_formal_properties bp

            # ~

            fp.remove :VCS_adapter_name

            bp.replace_by :VCS_adapter_name do | prp |
              prp.new_with_default do
                :git
              end
            end

            # ~

            fp.remove :system_conduit

            sys_cond = @parent.top_invocation_environment_x[ :__system_conduit__ ]
              # (let hacks in - the way this is written is nasty #todo)

            sys_cond ||= Home_.lib_.open3

            bp.replace_by :system_conduit do | prp |
              prp.new_with_default do
                sys_cond
              end
            end

            # ~

            fp.add_to_front :width, ( fp.at_position( 0 ).class.new do

              @name = Callback_::Name.via_variegated_symbol( :width )
              @parameter_arity = :one

              add_normalizer_for_greater_than_or_equal_to_integer 1
            end )

            # ~

            @back_properties = bp
            @front_properties = fp

            # ~

            @bound.receive_stderr_ @resources.serr

            NIL_
          end

          def prepare_backstream_call x_a

            # :+[#br-049] hacks like these are temporary.
            # this is a :+#frontier for a front-only prop with validation

            sym = x_a.fetch 0

            _arg = Callback_::Qualified_Knownness.via_value_and_variegated_symbol(
              x_a.fetch( 1 ), sym )

            bx = @front_properties.fetch( sym ).ad_hoc_normalizer_box

            _p = bx.h_.fetch( bx.a_.first )

            arg = _p.call _arg do | * i_a, & ev_p |

              receive_event_on_channel ev_p[], i_a
            end

            x_a[ 0, 2 ] = EMPTY_A_

            arg and begin
              @width = arg.value_x
              ACHIEVED_
            end
          end

          def bound_call_via_bound_call_from_back bc  # frontier experiment of :+[#br-060]

            @bound_call_from_back = bc

            Callback_::Bound_Call.via_receiver_and_method_name self, :__render
          end

          def __render

            ok = __via_bound_call_from_back_resolve_bundle
            ok &&= __via_bundle_resolve_sparse_matrix_of_content
            ok &&= __via_sparse_matrix_of_content_resolve_column_A
            ok && __via_column_A_render
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

            table = CLI_::Models_::Sparse_Matrix_of_Content.
              new_via_bundle_and_repository @bundle, @repo

            table and begin
              @matrix = table
              ACHIEVED_
            end
          end

          def __via_sparse_matrix_of_content_resolve_column_A

            st = Home_.lib_.tree.via( :node_identifiers,
              @matrix.rows ).to_classified_stream_for :text

            st.gets  # the first node is always the root node,
              # which never has any visual representation

            max = 0
            column_A_content = []
            column_B_rows = []
            begin
              o = st.gets
              o or break
              node, prefix_string = o.to_a
              s = "#{ prefix_string }#{ node.slug }"
              column_A_content.push s

              if node.is_leaf

                column_B_rows.push node.node_payload

                d = s.length  # or include the branch nodes. it's a design choice
                if max < d
                  max = d
                end
              else
                column_B_rows.push nil
              end
              redo
            end while nil

            @column_A = column_A_content
            @column_A_max_width = max
            @column_B_rows = column_B_rows

            ACHIEVED_
          end

          def __via_column_A_render

            CLI_::Actors_::Scale_time[
              @column_B_rows,
              @column_A_max_width,
              @column_A,
              @width,
              CLI_::Sessions_::Glyph_Mapper.start( * GLYPHS___ ),
              @resources.sout ]
          end
        end
      end

      Autoloader_[ self ]  # because it is parent module, not this one, that punches the load

      CLI_ = self

    end
  end
end

# :+#tombstone:  o.base.long[ 'use-mocks' ] = ::OptionParser::Switch::NoArgument.new do  # :+#hidden-option
# (keep this line for posterity - there was some AMAZING foolishness going
# on circa early '12 that is a good use case for why autoloader #todo)
