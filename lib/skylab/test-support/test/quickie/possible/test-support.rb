require_relative '../../test-support'

module Skylab::TestSupport::TestSupport::Quickie

  ::Skylab::TestSupport::TestSupport[ self ]

end

module Skylab::TestSupport::TestSupport::Quickie::Possible_

  ::Skylab::TestSupport::TestSupport::Quickie[ Possible_TS_ = self ]

  TestSupport_ = ::Skylab::TestSupport
  Quickie = TestSupport_::Quickie
    Possible_ = Quickie::Possible_

  extend Quickie

  LIB_ = TestSupport_._lib

  module Articulator_

    Articulator_ = Quickie::Possible_::Articulator_

  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def recon from_i, to_i, sig_a
      possible_graph.reconcile y, from_i, to_i, sig_a
    end

    def recon_plus from_i, to_i, sig_a
      possible_graph.reconcile_with_path_or_failure y, from_i, to_i, sig_a
    end

    def y
      @y ||= begin
        @do_debug ||= false
        @err_a = [ ]
        ::Enumerator::Yielder.new do |msg|
          @do_debug and LIB_.stderr.puts "(dbg:#{ msg })"
          @err_a << msg
          nil
        end
      end
    end

    def expect_line msg
      instance_variable_defined? :@err_a or fail "@err_a not set - #{
        }was `y` never called?"
      @err_a.length.zero? and fail "there are no more lines, expected one."
      (( @err_a.shift )).should eql( msg )
      nil
    end

    def expect_no_more_lines
      @err_a.length.should be_zero
      nil
    end

    def expect_only_line msg
      expect_line msg
      expect_no_more_lines
    end

    def new_sig x=:meh
      possible_graph.new_graph_signature x
    end
  end
end
