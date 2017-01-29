module Skylab::Zerk::TestSupport

  module CLI::Microservice_Toolkit

    def self.[] tcc

      Use_::Memoizer_methods[ tcc ]
      This_one_lib___[][ tcc ]
      tcc.send :define_singleton_method, :invoke_appropriate_action, IAA__
      tcc.include self
    end

    This_one_lib___ = Lazy_.call do
      Home_::Require_brazen_[]
      _ = Home_::Brazen_.test_support
      _ = _.lib_ :CLI_support_expectations
      _
    end

    IAA__ = -> do  # infer appropriate action

      define_method :invoke do | * argv |
        s = __appropriate_action_slug
        @appropriate_action_slug_ = s
        argv.unshift s
        using_expect_stdout_stderr_invoke_via_argv argv
      end
    end

    define_method :__appropriate_action_slug, -> do

      cache = {}
      -> do
        cls = client_class_
        cache.fetch cls do
          i_a = cls.instance_methods( false )
          1 == i_a.length or fail
          cache[ cls ] = i_a.fetch( 0 ).id2name.gsub UNDERSCORE_, DASH_
        end
      end
    end.call

    def immutable_helpscreen_state_via_invoke_ * argv

      # (will probably deprecate for the next method)

      _same argv
    end

    def immutable_lax_helpscreen_state_via_invoke_ * argv

      _same :lax_parsing, argv
    end

    def _same * x_a, argv

      using_expect_stdout_stderr_invoke_via_argv argv

      _state = flush_frozen_state_from_expect_stdout_stderr

      x_a.push :state, _state, :stream, :e

      _cls = TS_::CLI::Expect_Section_Fail_Early::Help_Screen_State

      _cls.via_iambic x_a
    end

    def expect_section_ k, exp  # assume `state_`

      _t = state_.lookup k
      _act = _t.to_string :unstyled
      _act.should eql exp
    end

    def expect_common_failure_

      expect_this_usage_
      expect_specific_invite_line_
      expect_failed
    end

    def expect_specific_invite_line_

      expect :styled, :e, /\Ause 'zeepo #{ @appropriate_action_slug_ } -h'#{
        } for help\z/
    end

    def expect_succeeded_with_ s
      expect :o, s
      expect_succeeded
    end

    def subject_class_
      Home_::CLI::MicroserviceToolkit::IsomorphicMethodsClient
    end

    def subject_CLI  # for one or more of our bundles
      client_class_
    end

    s = 'zeepo'.freeze
    s_a = [ s ].freeze

    define_method :get_invocation_strings_for_expect_stdout_stderr do
      s_a
    end
  end
end