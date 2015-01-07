require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Argument::Syntax

  ::Skylab::Headless::TestSupport::CLI::Argument[ TS__ = self ]

  include Constants

  Headless_ = Headless_

  extend TestSupport_::Quickie

  module ModuleMethods

    def with p
      parameters = p.parameters
      define_method :ruby_para_a do parameters end
    end
  end

  module InstanceMethods

    def with * actual_i_a
      @actual_i_a = actual_i_a ; nil
    end

    def ok
      execute
      @x and fail "expected ok, had extra"
      @m and fail "expected ok, had missing" ; nil
    end

    def missing * exp_i_a
      execute
      @x and fail "had extra expected missing"
      @m or fail "expecting missing, but no missing event was issued"
      formal_data_a = ruby_para_a
      @m.syntax_slice.each_argument.with_index do |farg, count|
        exp_i = exp_i_a.fetch count
        _act_i = farg.name.as_variegated_symbol
        _fdata_i = formal_data_a.fetch( farg.syntax_index_d ).fetch( 1 )
        _act_i.should eql exp_i
        _fdata_i.should eql exp_i
      end
    end

    def extra * i_a
      execute
      @m and fail "had missing expected extra"
      @x or fail "expecting extra but no extra event was issued"
      @x.s_a.should eql i_a ; nil
    end

    def execute
      @m = @x = nil  # miss / xtra
      stx = Headless_::CLI.argument.syntax.isomorphic.new ruby_para_a
      stx.process_args @actual_i_a do |o|
        o.on_missing do |ev|
          @m = ev ; false
        end
        o.on_extra do |ev|
          @x = ev ; false
        end
      end
    end
  end
end
