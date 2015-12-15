require 'skylab/css_convert'
require 'skylab/test_support'

module Skylab::CSS_Convert::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    def use sym

      USE___.fetch( sym ).call self
    end
  end

  USE___ = {

    expect_event: -> tcc do
      Home_::Callback_.test_support::Expect_Event[ tcc ]
    end,

    my_CLI_expectations: -> tcc do
      Home_::Brazen_.test_support.lib( :CLI_support_expectations )[ tcc ]
      tcc.class_exec do

        def subject_CLI
          Home_::CLI
        end

        def get_invocation_strings_for_expect_stdout_stderr
          [ 'czz' ]
        end
      end
    end,
  }

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def fixture_path_ tail
      ::File.join FIXTURES_DIR___, tail
    end

    def build_CSS_parser__

      _build_parser Home_::CSS_::Parser
    end

    def parse_directives_in_file_ path

      _parser = _build_parser Home_::Directive__::Parser
      _parse_path_using_parser path, _parser
    end

    def _parse_path_using_parser path, parser

      parser.parse_path path
    end

    def _build_parser cls

      # if the parser emits old-style resource-based events,
      # we turn them into new-style selective events.

      p = event_log.handle_event_selectively  # from `expect_event`

      _rsx = Selective_Listener_as_Resources___.new( & p )

      cls.new Home_.lib_.my_sufficiently_existent_tmpdir, _rsx, & p
    end
  end

  class Selective_Listener_as_Resources___

    attr_reader(
      :serr,
    )

    def initialize & oes_p

      @serr = Home_.lib_.basic::String::Receiver::As_IO.new do | o |

        o[ :receive_line_args ] = -> a do

          # when we call `puts` on our stderr proxy, turn it into an event:

          oes_p.call :info, :expression, :line do | y |
            y.send :<<, * a
          end
          NIL_
        end
      end
    end

    def sin
      Home_.lib_.system.test_support::MOCKS.interactive_STDIN_instance
    end

    def sout
      :__NO_SOUT__
    end
  end

  Home_ = ::Skylab::CSS_Convert

  FIXTURES_DIR___ = ::File.expand_path( '../fixtures', __FILE__ )

  NIL_ = nil

end
