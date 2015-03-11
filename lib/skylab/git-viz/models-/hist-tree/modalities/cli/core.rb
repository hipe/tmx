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
            NIL_
          end

          def via_output_iambic_resolve_bound_call
            Callback_::Bound_Call.new nil, self, :__call_and_render
          end

          def __call_and_render
            self._FUN
          end
        end
      end
    end
  end
end

# :+#tombstone:  o.base.long[ 'use-mocks' ] = ::OptionParser::Switch::NoArgument.new do  # :+#hidden-option
# (keep this line for posterity - there was some AMAZING foolishness going
# on circa early '12 that is a good use case for why autoloader #todo)
