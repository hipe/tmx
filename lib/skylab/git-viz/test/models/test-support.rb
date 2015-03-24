require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module ModuleMethods

    def memoize sym, & p

      define_singleton_method sym, & Callback_.memoize( & p )

      define_method sym do

        self.class.send sym
      end
    end
  end

  module InstanceMethods

    def subject_API  # #hook-out for "expect event"
      GitViz_::API
    end

    def black_and_white_expression_agent_for_expect_event
      GitViz_.lib_.brazen::API.expression_agent_instance
    end
  end

  # ~

  Bundle_Support = -> tcm do

    require Top_TS_::VCS_Adapters::Git.dir_pathname.join( 'test-support' ).to_path  # reach down meh

    Top_TS_::VCS_Adapters::Git::Bundle_Support[ tcm ]
  end

  module Hist_Tree_Model_Support

    class << self

      def [] tcm

        Top_TS_::Expect_Event[ tcm ]
        GitViz_::Test_Lib_::Mock_FS[ tcm ]
        GitViz_::Test_Lib_::Mock_System[ tcm ]

        tcm.include self

        NIL_
      end
    end  # >>

    def call_API_for_hist_tree_against_path_ path

      call_API(
        * hist_tree_head_iambic_,
        :path, mock_pathname( path ),
        :system_conduit, mock_system_conduit )
    end

    define_method :hist_tree_head_iambic_, -> do
      a = [ :hist_tree, :VCS_adapter_name, :git ].freeze
      -> do
        a
      end
    end.call

  end

  # ~

  Callback_ = Callback_
  GitViz_ = GitViz_
  NIL_ = NIL_
  Top_TS_ = Top_TS_

end
