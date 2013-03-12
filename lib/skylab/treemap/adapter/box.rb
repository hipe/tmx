module Skylab::Treemap

  class Adapter::Box < MetaHell::Formal::Box

    def each *a
      @hot or load
      super
    end

    def fuzzy_reduce ref
      res = _fuzzy_reduce ref,
        -> k, v, y do
          y << v.slug
        end
    end

  protected

    def initialize box_module, client_filename
      super( )
      @box_module, @client_filename = box_module, client_filename
      @hot = nil
      nil
    end

    def load
      @box_module.each do |const, mod|
        mote = Adapter::Catalyzer.new const, mod
        add mote.normalized_local_adapter_name, mote
      end
      @hot = true
    end
  end
end
