module Skylab::SubTree::TestSupport

  module Operations::Files

    def self.[] tcc
      tcc.include self
    end

    head = nil

    define_method :fixture_file do | sym |

      head ||= ::File.join TS_.dir_path, 'fixture-files'

      _tail = "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.output"

      ::File.join head, _tail
    end

    def build_string_IO
      Home_::Library_::StringIO.new
    end

    def mock_noninteractive_IO_
      Home_.lib_.system.test_support::STUBS.noninteractive_IO_instance
    end

    def black_and_white_expression_agent_for_expect_emission
      produce_action_specific_expag_safely_
    end

    def produce_action_specific_expag_safely_
      Expag_for_tests[]
    end

    Expag_for_tests = Common_::Lazy.call do

      expag = Home_::CLI::ExpressionAgent.new :_dummy_reflection_

      # EEK:

      def expag.par x
        par_via_sym x.name_symbol
      end

      def expag.par_via_sym _
        "«#{ _.id2name.gsub UNDERSCORE_, DASH_ }»"  # #guillemets
      end

      expag
    end

    pretty = nil
    define_method :_PRETTY_ do
      pretty ||= <<-HERE.unindent
        one
        ├── foo.kode
        └── test
            └── foo_spec.kode
      HERE
    end

    Here_ = self
  end
end
