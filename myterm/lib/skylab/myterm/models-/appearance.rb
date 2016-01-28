module Skylab::MyTerm

  class Models_::Appearance  # notes (were) in [#003]

    def initialize ke

      @adapter = nil
      @adapters = nil

      @kernel_ = ke
    end

    def __adapter__component_association

      Models_::Adapter
    end

    def __adapters__component_association

      Models_::Adapters
    end

    # -- let children violate [#ac-002]#DT1 autonomy:

    attr_reader(
      :kernel_,
    )
  end
end
# #tombstone: (un)serialization
