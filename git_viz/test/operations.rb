module Skylab::GitViz::TestSupport

  module Operations

    def self.[] tcc
      TS_::Reactive_Model[ tcc ]
      TS_::Double_Decker_Memoize[ tcc ]
      NIL_
    end

    # ~ bundles

    module Hist_Tree_Model

      class << self

        def [] tcm

          TS_::Want_Event[ tcm ]
          TS_::Stubbed_filesystem[ tcm ]
          TS_::Stubbed_system[ tcm ]

          tcm.include TS_::Reactive_Model[ self ]
          tcm.include self

          NIL_
        end
      end  # >>

      def call_API_for_hist_tree_against_path_ path

        call_API(
          * hist_tree_head_iambic_,
          :path, path,
          :system_conduit, stubbed_system_conduit,
          :filesystem, stubbed_filesystem,
        )
      end

      define_method :hist_tree_head_iambic_, -> do
        a = [ :hist_tree, :VCS_adapter_name, :git ].freeze
        -> do
          a
        end
      end.call
    end

    # ==
    # ==
  end
end
# #history-A.1: de-abstracted facilities. moved stub classes to test file
