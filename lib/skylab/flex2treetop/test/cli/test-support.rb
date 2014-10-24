require_relative '../my-test-support'

module Skylab::Flex2Treetop::MyTestSupport

  module CLI

    # ~ test phase

    module ModuleMethods
      include Headless::ModuleMethods  # e.g 'fixture'
    end

    module InstanceMethods
      include Headless::InstanceMethods
      def add_any_outstream_to_IO_spy_group grp  # #hook-out
        grp.add_stream :stdout  # this is a normal IO spy.  the default CLI
      end                       # paystream is stdout (not so with API)
      def invoke * argv
        _client = _CLI_client
        @result = _client.invoke argv
      end
      def _CLI_client
        @CLI_client ||= bld_CLI_client
      end
      def bld_CLI_client
        _grp = _IO_spy_group
        cli = F2TT_::CLI.new( * _grp.to_a )
        cli.program_name = PROGNAME_
        cli
      end
    end
    PROGNAME_ = 'xyzzy'.freeze

    # ~ assertion phase

    module InstanceMethods

      def expect_header i
        expect :styled, /\A#{ ::Regexp.escape i.id2name  }:\z/
      end

      def expect_blank
        s = gets_some_chopped_line
        s.length.should be_zero
      end

      def expect_usage_and_invite
        expect_usage
        expect_invite
        expect_failed
      end

      def expect_usage
        expect :styled, /\Ausage: xyzzy.+-g=<grammar>/i
      end

      def expect_invite
        expect :styled, /\Ause xyzzy -h for help\z/
      end

      def expect_failed
        expect_no_more_lines
        @result.should eql false
      end

      def release_some_emission
        @bkd_em_a.shift ; nil
      end
    end
  end
end
