module Skylab::GitViz

  # [#006] is the CLI client narrative

  class Models_::HistTree

    Modalities = ::Module.new

    module Modalities::CLI

      module Actions

        class Hist_Tree < GitViz_.lib_.brazen::CLI::Action_Adapter

          def resolve_properties  # #nascent-operation :+[#br-042]

            bp = @bound.formal_properties.to_mutable_box_like_proxy
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

            sys_cond = @parent.env_[ :__system_conduit__ ]  # let hacks in
            sys_cond ||= GitViz_.lib_.open3

            bp.replace_by :system_conduit do | prp |
              prp.new_with_default do
                sys_cond
              end
            end

            # ~

            @back_properties = bp
            @front_properties = fp

            # ~

            @bound.receive_stderr_ @resources.serr

            NIL_
          end

          def bound_call_via_bound_call_from_back bc  # frontier experiment of :+[#br-060]

            @bound_call_from_back = bc

            Callback_::Bound_Call.new nil, self, :__render
          end

          def __render

            ok = __via_bound_call_from_back_resolve_bundle
            ok &&= __via_bundle_resolve_rows
            ok &&= __via_rows_resolve_column_A
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


          def __via_bundle_resolve_rows

            table = CLI_::Models_::Table.new_via_bundle_and_repository(
              @bundle, @repo )

            table and begin
              @glyph_mapper = table.glyph_mapper
              @rows = table.rows
              ACHIEVED_
            end
          end

          def __via_rows_resolve_column_A

            st = GitViz_.lib_.tree.from( :node_identifiers,
              @rows ).to_classified_stream_for :text

            st.gets  # the first node is always the root node,
              # which never has any visual representation

            max = 0
            column_A_content = []
            column_B_row = []
            begin
              o = st.gets
              o or break
              node, prefix_string = o.to_a
              s = "#{ prefix_string }#{ node.slug }"
              column_A_content.push s

              if node.is_leaf

                column_B_row.push node.node_payload

                d = s.length  # or include the branch nodes. it's a design choice
                if max < d
                  max = d
                end
              else
                column_B_row.push nil
              end
              redo
            end while nil

            @column_A = column_A_content
            @column_A_max_width = max
            @column_B_row = column_B_row
            ACHIEVED_
          end

          def __via_column_A_render

            # (this may get more interesting in the next commit)

            a = @column_B_row
            fmt = "%-#{ @column_A_max_width }s |"
            io = @resources.sout

            cg_s = @glyph_mapper.create_glyph
            s_a = @glyph_mapper.glyphs

            @column_A.each_with_index do | s, d |

              io << fmt % s

              row = a[ d ]
              if row
                row.a.each do | x |
                  io << SPACE_
                  if x
                    if x.is_first
                      io << cg_s
                    else
                      io << s_a.fetch( x.amount_classification )
                    end
                  else
                    io << SPACE_
                  end
                end
              end
              io << NEWLINE_
            end
            ACHIEVED_
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
