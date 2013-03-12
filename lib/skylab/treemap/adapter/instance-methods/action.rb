module Skylab::Treemap
  module Adapter::InstanceMethods::Action
    #
    # (please sdon't confuse these with adapter action instance-methods --
    # these below are instance methods for actions that will work with
    # adapters, the other is something else!)

    def adapters= box  # hacked for now..
      @adapters = box
    end

    def adapter_box
      @adapter_box ||= api_client.adapter_box
    end

    attr_accessor :catalyzer

    def resolve_adapter adapter_ref, otherwise=nil
      msg = nil
      found = adapter_box.fuzzy_fetch adapter_ref,
        -> do
          a = adapter_box.map(&:slug)
          msg = "not found. #{ s a, :no }known adapter#{ s a } #{ s a, :is } #{
            }#{ and_ a.map(& method(:pre)) }".strip
          nil
        end,
        -> x { x },
        -> match_box do
          a = match_box.map { |md| md.item.as_slug }
          msg = "is ambiguous -- did you mean #{ or_ a.map(& method(:pre)) }?"
          nil
        end
      res = if found then found else
        msg = "adapter #{ ick adapter_ref } #{ msg }"
        otherwise ? otherwise[ msg ] : error( msg )
      end
      res
    end

    # actions themselves may chose to delegate up to a modality client to
    # wire this action however we end up deciding to do it..

    def build_wired_adapter_action kls
      request_client.build_wired_adapter_action kls
    end
  end
end
