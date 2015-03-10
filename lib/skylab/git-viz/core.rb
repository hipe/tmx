
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def mock_FS
      GitViz_::Test_Lib_::Mock_FS
    end
  end  # >>

  # ~ begin :+[#br-027] experiment towards a zero-config API

  module API

    class << self

      def call * x_a, & oes_p

        lib = GitViz_.lib_.brazen

        oes_p and x_a.push( :on_event_selectively, oes_p )

        @__app_kernel__ ||= lib::Kernel_.new GitViz_

        cb = lib::API.bound_call_session.call(
          x_a, @__app_kernel__, GitViz_ )

        cb and cb.receiver.send cb.method_name, * cb.args
      end
    end  # >>
  end

  # ~ end

  # ~ begin #change-this-at-step:7

  class CLI
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
    def initialize * a
      @sin, @sout, @serr, @invo_s_a = a
    end
    def invoke argv
      if %w( ping ) == argv
        @serr.puts "hello from git viz."
        :hello_from_git_viz
      end
    end
  end

  # ~ end

  Autoloader_ = ::Skylab::Callback::Autoloader
    Callback_ = ::Skylab::Callback

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true

  Callback_Tree_ = Callback_::Tree

  CONTINUE_ = nil

  DASH_ = '-'.freeze

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> {}

  GitViz_ = self

  Name_ = Callback_::Name

  NIL_ = nil

  Scn_ = Callback_::Scn

  SPACE_ = ' '.freeze

  UNABLE_ = false

  UNDERSCORE_ = '_'.freeze

end
