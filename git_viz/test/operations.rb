module Skylab::GitViz::TestSupport

  module Models::Support

    def self.[] tcc

      TS_::Reactive_Model_Support[ tcc ]
      TS_::Double_Decker_Memoize[ tcc ]
      NIL_
    end

    # ~ bundles

    module Hist_Tree_Model_Support

      class << self

        def [] tcm

          TS_::Expect_Event[ tcm ]
          TS_::Stubbed_filesystem[ tcm ]
          TS_::Stubbed_system[ tcm ]

          tcm.include TS_::Reactive_Model_Support[ self ]
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

    Mocks = -> do

      mock = -> do

        Mock_Filechange = ::Struct.new :author_datetime, :change_count

        Mock_Row = ::Struct.new :to_a

        mock = -> do
          This_Guy_
        end
        This_Guy_
      end

      -> tcc do

        tcc.send :define_method, :_Mock_Filechange_ do
          mock[]::Mock_Filechange
        end

        tcc.send :define_method, :_Mock_Row_ do
          mock[]::Mock_Row
        end

      end
    end.call

    This_Guy_ = self
  end
end
