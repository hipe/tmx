require 'skylab/css_convert'
require 'skylab/test_support'

module Skylab::CSS_Convert::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  TestSupport_::Quickie.enable_kernel_describe

  # -

    Use_method___ = -> sym do
      USE___.fetch( sym ).call self
    end

  # -

  USE___ = {

    want_event: -> tcc do
      Home_::Common_.test_support::Want_Emission[ tcc ]
    end,

    my_CLI_expectations: -> tcc do
      Home_::Brazen_.test_support.lib( :CLI_support_expectations )[ tcc ]
      tcc.class_exec do

        def subject_CLI
          Home_::CLI
        end

        def get_invocation_strings_for_want_stdout_stderr
          [ 'czz' ]
        end
      end
    end,
  }

  module InstanceMethods___

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

      p = event_log.handle_event_selectively  # from `want_event`

      _rsx = Selective_Listener_as_Resources___.new( & p )

      _tmpdir = Home_.lib_.my_sufficiently_existent_tmpdir

      cls.new _tmpdir, _rsx, & p
    end
  end

  class Selective_Listener_as_Resources___

    attr_reader(
      :serr,
    )

    def initialize & p

      @serr = Basic_[]::String::Receiver::As_IO.new do | o |

        o[ :receive_line_args ] = -> a do

          # when we call `puts` on our stderr proxy, turn it into an event:

          p.call :info, :expression, :line do | y |
            y.send :<<, * a
          end
          NIL_
        end
      end
    end

    def sin
      Home_.lib_.system.test_support::STUBS.interactive_STDIN_instance
    end

    def sout
      :__NO_SOUT__
    end
  end

  Home_ = ::Skylab::CSS_Convert

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Basic_ = Home_::Basic_
  FIXTURES_DIR___ = ::File.expand_path '../fixture-files', __FILE__
  NIL_ = nil
  TS_ = self
end
