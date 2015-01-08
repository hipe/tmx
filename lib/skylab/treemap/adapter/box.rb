module Skylab::Treemap

  class Adapter::Box < Callback_::Box

    def each *a
      @hot or load
      super
    end

    def fuzzy_reduce ref
      _fuzzy_reduce ref,
        -> k, v, y do
          y << v.slug
        end
    end

  private

    def initialize box_module, client_filename
      super( )
      @box_module, @client_filename = box_module, client_filename
      @hot = nil
      nil
    end

    def load
      @hot = true
      @box_module.each_const_pair do |const_i, mod|
        mote = Adapter::Catalyzer.new const_i, mod
        add mote.normalized_local_adapter_name, mote
      end ; nil
    end
  end
end
