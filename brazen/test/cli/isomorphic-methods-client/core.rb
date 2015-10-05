module Skylab::Brazen::TestSupport

  module CLI::Isomorphic_Methods_Client

    def self.[] tcc

      TS_::CLI::Expect_CLI[ tcc ]
      TS_::TestLib_::Danger_memo[ tcc ]

      tcc.extend VERY_TEMPORARY_LEGACIES
      tcc.include self

      tcc.send :define_singleton_method, :invoke_appropriate_action, IIA__
    end

    module VERY_TEMPORARY_LEGACIES

      def client_cls_with_op _
      end
      def with_action_class
      end
      def action_class_with_DSL _
      end
    end

    # ~ infer appropriate action

    IIA__ = -> do

      define_method :invoke do | * argv |
        s = __appropriate_action_slug
        @appropriate_action_slug_ = s
        argv.unshift s
        using_expect_stdout_stderr_invoke_via_argv argv
      end
    end

    define_method :__appropriate_action_slug, -> do

      cache = {}
      _DASH = '-' ; _UNDERSCORE = '_'

      -> do
        cls = client_class_
        cache.fetch cls do
          i_a = cls.instance_methods( false )
          1 == i_a.length or fail
          cache[ cls ] = i_a.fetch( 0 ).id2name.gsub _UNDERSCORE, _DASH
        end
      end
    end.call

    # ~ end

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
      Home_::CLI::Isomorphic_Methods_Client
    end

    def subject_CLI  # for one or more of our bundles
      client_class_
    end

    define_method :get_invocation_strings_for_expect_stdout_stderr, -> do
      a = %w( zeepo )
      -> do
        a
      end
    end.call
  end
end
