module Skylab::Treemap
  module Adapter::InstanceMethods::Action

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
          a = match_box.map { |md| md.item.to_slug }
          msg = "is ambiguous -- did you mean #{ or_ a.map(& method(:pre)) }?"
          nil
        end
      res = if found then found else
        msg = "adapter #{ ick adapter_ref } #{ msg }"
        otherwise ? otherwise[ msg ] : error( msg )
      end
      res
    end
  end
end
