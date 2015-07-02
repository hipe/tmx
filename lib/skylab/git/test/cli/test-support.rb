require_relative '../test-support'

module Skylab::Git::TestSupport::CLI

  ::Skylab::Git::TestSupport[ self ]

  include Constants

  ERR_I__ = :errstream
  Home_ = Home_
  OUT_I__ = :outstream
  TestLib_ = TestLib_

  module Constants
    ERR_I = ERR_I__
    OUT_I = OUT_I__
  end

  module InstanceMethods

    # ~ test-time support

    def invoke_from_workdir * x_a
      r = nil ; Home_::Library_::FileUtils.cd workdir_pn.to_s do
        r = invk x_a
      end ; r
    end

    def invoke * x_a
      invk x_a
    end

    def invk s_a
      1 == s_a.length and s_a[ 0 ].respond_to?( :each_with_index ) and
        s_a = s_a[ 0 ]
      @result = _CLI_client.invoke s_a  # #call-out
    end

    # ~ ~ support for building clients

    # ~ ~ ~ two stream spying

    let :two_spy_group do
      spy = TestLib_::IO_spy_group[].new
      spy.do_debug_proc = -> { do_debug }
      spy.add_stream OUT_I__ ; spy.add_stream ERR_I__
      spy
    end

    # ~ assertion-time support

    def expect styled_i=nil, stream_i, exp_x
      baked_a = bkd_a
      line = baked_a.shift
      line or fail "expected at least one more '#{ stream_i }' line, had none"
      line.stream_symbol.should eql stream_i
      s = line.string.chomp!
      styled_i and s = filter_for_style_expectation( styled_i, s )
      if exp_x.respond_to? :named_captures
        s.should match exp_x
      else
        s.should eql exp_x
      end ; nil
    end

    def filter_for_style_expectation i, s
      STYLED_ENUM_H__.fetch i
      send :"filter_for_#{ i }_expectation", s
    end
    STYLED_ENUM_H__ = { styled: true, nonstyled: true }.freeze
    def filter_for_styled_expectation s
      s_ = unstyle_styled s
      s_ or fail "expected styled line, had #{ s.inspect }"
    end
    def filter_for_nonstyled_expectation s
      STYLE_RX__ =~ s and fail "expected nonstyled line, had #{ s.inspect }"
      s
    end

    styling = Home_.lib_.brazen::CLI::Styling

    STYLE_RX__ = styling::SIMPLE_STYLE_RX

    styling.each_pair_at :unstyle_styled, & method( :define_method )

    def contiguous_string_from_lines_on i
      line_a = bkd_a
      s_a = []
      while line_a.length.nonzero? and i == line_a[ 0 ].stream_symbol
        line = line_a.shift
        s_a << line.string
      end
      s_a * ES__
    end

    ES__ = ''.freeze

    def expect_styled str
      filter_for_styled_expectation str
    end

    def expect_no_more_lines
      if bkd_a.length.nonzero?
        no = @baked_a.fetch 0
        fail "expected no more lines, had at least #{
          }on more: [#{ no.stream_symbol.inspect }, #{ no.string.inspect }]"
      end
    end

    def bkd_a
      @baked_a ||= bake
    end

    def bake
      two_spy_group.release_lines
    end

    Baked__ = ::Struct.new OUT_I__, ERR_I__
  end
end
