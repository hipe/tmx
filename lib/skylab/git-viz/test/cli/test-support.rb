require_relative '../test-support'

module Skylab::GitViz::TestSupport::CLI

  ::Skylab::GitViz::TestSupport[ TS__ = self ]

  module Constants
    PROGNAME_ = 'gv'.freeze
  end

  include Constants

  GitViz = GitViz ; PROGNAME_ = PROGNAME_ ; TestSupport = TestSupport

  extend TestSupport::Quickie

  module InstanceMethods

    # ~ action-under-test phase

    def invoke * s_a
      @result = client.invoke s_a ; nil
    end

    def client
      @client ||= build_client
    end

    def build_client
      grp = _IO_spy_group
      cli = GitViz::CLI::Client.new( * grp.values_at( :i, :o, :e ) )
      cli.program_name = PROGNAME__
      cli
    end

    PROGNAME__ = PROGNAME_

    def _IO_spy_group
      @IO_spy_group ||= bld_IO_spy_group
    end

    def bld_IO_spy_group
      grp = TestSupport::IO.spy.group.new
      grp.debug_IO = debug_IO
      grp.do_debug_proc = -> { do_debug }
      grp.add_stream :i, :_no_instream_
      grp.add_stream :o
      grp.add_stream :e
      grp
    end

    # ~ assertion phase
    def expect_expecting_line_with_action_subset * i_a
      _s_a = i_a.map { |i| i.id2name.gsub( '_', '-' ) }
      subset = GitViz::Lib_::Set[].new _s_a
      expect_expecting_line do
        _s_a_ = @md[ :altrntn ].split( / *\| */ )
        superset = ::Set.new _s_a_
        outside = subset - superset
        outside.count.zero? or fail say_outside( outside )
      end
    end

    def expect_expecting_line &p
      expect :styled, EXPECTING_RX__, &p
    end
    RXS__ = '[-a-z]+'
    ALT_INNER_RXS__ = " *#{ RXS__ }(?: *\\| *#{ RXS__ })* *"
    EXPECTING_RX__ = /\Aexpecting \{(?<altrntn>#{ ALT_INNER_RXS__ })\}\.?\z/

    def say_outside outside
      "these action name(s) were outside of the alternation term: #{
        }(#{ outside.to_a * ', ' })"
    end

    def expect_usaged_and_invited
      expect_usage_line
    end

    def expect_invited
      expect_invite_line
      expect_failed
    end

    def expect_usage_line
      expect :styled, USAGE_LINE_RX__
    end

    ALTERNATION_RXS__ = "\\{#{ ALT_INNER_RXS__ }\\}"
    USAGE_LINE_RX__ = /\Ausage: #{ PROGNAME__ } #{
      }#{ ALTERNATION_RXS__ } \[opts\] \[args\]\z/

    def expect_invite_line
      expect :styled, INVITE_LINE_RX__
    end
    INVITE_LINE_RX__ = /\ATry #{ PROGNAME__ } -h for help\.?\z/

    def expect_failed
      expect_result_for_failure
      expect_no_more_lines
    end

    def expect_succeeded
      expect_result_for_success
      expect_no_more_lines
    end

    def expect_result_for_success
      @result.should eql 0
    end

    def expect_result_for_failure
      @result.should eql 1
    end

    def expect_blank_line
      expect BLANK_LINE__
    end
    BLANK_LINE__ = ''.freeze

    def expect_no_more_lines
      expect_no_more_emissions
    end

    def build_baked_em_a
      _IO_spy_group.release_lines
    end
  end
end
