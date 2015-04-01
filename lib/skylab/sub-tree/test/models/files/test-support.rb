require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_Files

  ::Skylab::SubTree::TestSupport[ TS_ = self, :filename, 'models/files' ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def build_string_IO
      SubTree_::Library_::StringIO.new
    end

    def fixture_file sym
      Fixture_Files[ sym ]
    end

    def black_and_white_expression_agent_for_expect_event
      produce_action_specific_expag_safely_
    end

    def produce_action_specific_expag_safely_

      # don't autoload yourself just to get the expag - ..

      if SubTree_.const_defined? :API
        SubTree_::Models_::Files::Modalities::CLI::EXPRESSION_AGENT
      else
        fail
      end
    end
  end

  # ~ longer consts

  module Fixture_Files
    class << self
      def [] sym

        TS_.dir_pathname.join(
          "fixture-files/#{ sym.id2name.gsub UNDERSCORE_, DASH_ }.output"
        ).to_path

      end
    end  # >>
  end

  MOCK_NONINTERACTIVE_IO_ = class Mock_Noninteractive_IO___

    def closed?
      false
    end

    def close
    end

    def tty?
      false
    end
    self
  end.new

  PRETTY_ = <<-HERE.unindent
    one
    ├── foo.rb
    └── test
        └── foo_spec.rb
  HERE

  # ~ short consts

  Callback_ = Callback_
  DASH_ = DASH_
  EMPTY_A_ = EMPTY_A_
  EMPTY_S_ = EMPTY_S_
  SubTree_ = SubTree_
  UNDERSCORE_ = UNDERSCORE_

end
