module Skylab::MyTerm

  class Models_::Appearance  # notes (were) in [#003]

    def initialize ke

      @adapter = nil
      @adapters = nil

      @kernel_ = ke
    end

    def __adapters__component_association

      Models_::Adapters
    end

    def __adapter__component_association

      Models_::Adapter
    end

    # -- inject assets from the adapter by hook-in to [ac]. more at [#003]

    def component_association_reader

      Require_ACS_[]

      my_asc_p = ACS_::Component_Association.  # (b.c we have no custom class)
        reader_of_component_associations_by_method_in self

      -> token_x do

        if @adapter
          asc = @adapter.association_if_associated__ token_x
        end
        if asc
          asc
        else
          my_asc_p[ token_x ]
        end
      end
    end

    def to_component_node_streamer
      self._K  # probably in #during #milestone-5
    end

    def component_value_reader

      mine = ACS_::By_Ivars::Value_reader_in[ self ]

      -> asc do
        if @adapter
          kn = @adapter.read_value__ asc
        end
        if kn
          kn
        else
          mine[ asc ]
        end
      end
    end

    def component_value_writer

      mine = ACS_::By_Ivars::Value_writer_in[ self ]

      -> qk do
        if @adapter
          did = @adapter.write_value_if_associated__ qk
        end
        if ! did
          mine[ qk ]
        end
      end
    end

    # -- let children violate [#ac-002]#DT1 autonomy:

    attr_reader(
      :adapter,
      :kernel_,
    )
  end
end
# #tombstone: (un)serialization
