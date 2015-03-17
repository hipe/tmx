
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  module CLI  # :+#stowaway

    class << self

      def new * a

        client = GitViz_.lib_.brazen::CLI.new_top_invocation(
          a, GitViz_.application_kernel_ )

        client.receive_environment MONADIC_EMPTINESS_

        client
      end
    end  # >>

    # ~ begin :+#hook-out for tmx
    Client = self
    module Adapter
      module For
        module Face
          module Of
            Hot = -> x, x_ do
              GitViz_.lib_.brazen::CLI::Client.fml GitViz_, x, x_
            end
          end
        end
      end
    end
    # ~ end
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = GitViz_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end
    end  # >>
  end

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( ::Skylab::Callback.memoize do
      GitViz_.lib_.brazen::Kernel.new GitViz_
    end )

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def mock_FS
      GitViz_::Test_Lib_::Mock_FS
    end

    def repository
      GitViz_::VCS_Adapters_::Git.repository
    end
  end  # >>

  Autoloader_ = ::Skylab::Callback::Autoloader
  ACHIEVED_ = true
  Callback_Tree_ = Callback_::Tree
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  GitViz_ = self
  Name_ = Callback_::Name
  NEWLINE_ = "\n"
  NIL_ = nil
  MONADIC_EMPTINESS_ = -> _ {}
  Scn_ = Callback_::Scn
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end
