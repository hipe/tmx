require_relative '../test-support'

module Skylab::Headless::TestSupport::API::SSA__

  ::Skylab::Headless::TestSupport::API[ TS__ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Headless_ = Headless_ ; TestSupport_ = TestSupport_

  module ModuleMethods
    def with_API_module & p
      define_method :_API_module, Headless_::Library_::Memoize[ p ]
    end
  end

  module InstanceMethods

    def _API_invoke * x_a
      @result = _API_module.invoke x_a[ 0 ],
        :program_name, PROGNAME,
        :errstream, _IO_spy_group[ :stderr ], * x_a[ 1 .. -1 ]
    end

    PROGNAME = 'bazknocker'.freeze

    def _IO_spy_group
      @IO_spy_group ||= build_IO_spy_group
    end

    def build_IO_spy_group
      grp = TestSupport_::IO::Spy::Group.new
      grp.debug_IO = debug_IO
      grp.do_debug_proc = -> { do_debug }
      grp.add_stream :stdin, :_no_instream_
      grp.add_stream :stdout, :_no_outstream_
      grp.add_stream :stderr
      grp
    end

    # ~ assertion phase

    def expect string_matcher_x
      line = shft_some_baked_chomped_line :stderr
      if string_matcher_x.respond_to? :name_captures
        line.should match string_matcher_x
      else
        line.should eql string_matcher_x
      end ; nil
    end
    def shft_some_baked_chomped_line stream_i
      emission = bkd_emission_a.shift
      emission or fail "expected more emissions, had none"
      emission.stream_name.should eql stream_i
      emission.string.chomp!
    end
    def bkd_emission_a
      @bkd_em_a ||= bk_emissions
    end
    def bk_emissions
      group = _IO_spy_group
      @IO_spy_group = :_IO_spy_group_was_baked_
      group.release_lines
    end
    def expect_no_more_lines
      bkd_emission_a.length.zero? or fail "expected no more lines had: #{
        }#{Headless__::Lib_::Strange[ @bkd_em_a.first ] }"
    end
  end
end
