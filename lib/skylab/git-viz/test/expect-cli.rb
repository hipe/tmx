module Skylab::GitViz::TestSupport

  module Expect_CLI

    class << self
      def [] test_mod
        test_mod.include TestSupport_::Expect_Stdout_Stderr::InstanceMethods
        test_mod.include self
      end
    end  # >>

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def subject_CLI
      GitViz_::CLI
    end

    define_method :invocation_strings_for_expect_stdout_stderr, -> do
      x = [ 'gvz'.freeze ].freeze
      -> { x }
    end.call

    # ~ assertion phase (ad-hocs)

    def expect_whine_about_unrecognized_action x
      expect :styled,
        %r(\Aunrecognized action:? ['"]?#{ ::Regexp.escape x }['"]?\z)i
    end

    def expect_whine_about_unrecognized_option x
      expect "invalid option: #{ x }"
    end

    def expect_express_all_known_actions

      _s = expect( :styled ) { |x| x }  # IDENTITY_
      _a = /\Aknown actions are \('([^\)]+)'\)\z/.match( _s )[ 1 ].split( "', '" )

      h = ::Hash[ the_list_of_all_visible_actions.map { |s| [ s, true ] } ]

      _a.each do | s |
        h.delete( s ) or fail self.__TODO_say_extra_action( s )
      end

      if h.length.nonzero?
        fail self.__TODO_say_missing_actions( h.keys )
      end
    end

    def expect_generic_expecting_line
      expect :styled, "expecting <action>"
    end

    def expect_usaged_and_invited
      expect_usage_line
      expect_generically_invited
    end

    def expect_usage_line
      expect :styled, "usage: gvz <action> [..]"
    end

    def expect_generically_invited
      expect_generic_invite_line
      expect_failed
    end

    def expect_generic_invite_line
      expect :styled, "use 'gvz -h' for help"
    end

    def expect_failed
      expect_no_more_lines
      expect_result_for_failure
    end

    def expect_succeeded
      expect_no_more_lines
      expect_result_for_success
    end

    def expect_result_for_failure
      @exitstatus.should eql _memo.generic_error
    end

    def expect_result_for_success
      @exitstatus.should be_zero
    end

    # ~ more ad-hoc

    def the_list_of_all_visible_actions
      %w( ping hist-tree )
    end


    # ~ BLUNK

    def expect_expecting_and_invited
      expect_expecting_line
      expect_invited ; nil
    end

    # ~ END

    define_method :_memo, -> do
      p = -> do

        a = [] ; a_ = []

        es = GitViz_.lib_.brazen::API.exit_statii
        a.push :generic_error ; a_.push es.fetch( :generic_error )

        Memo___ = ::Struct.new( * a ).new( * a_ )
        p = -> do
          Memo___
        end
        Memo___
      end
      -> do
        p[]
      end
    end.call

  end
end
