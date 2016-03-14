module Skylab::Brazen::TestSupport

  module CLI::Isomorphic_Methods_Client::Models::Isomorphic_Method_Parameters

    def self.[] tcc
      tcc.extend ModuleMethods
      tcc.include InstanceMethods
    end
    # <-

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
        _fdata_i = formal_data_a.fetch( farg.syntax_index ).fetch( 1 )
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

      _stx = Home_::CLI::Isomorphic_Methods_Client::Models_::
        Isomorphic_Method_Parameters.new ruby_para_a

      _stx.validate_against_args @actual_i_a do |o|

        o.on__missing__ do |ev|
          @m = ev
          :_unreliable_ # UNRELIABLE_
        end

        o.on__extra__ do |ev|
          @x = ev
          :_unreliable_ # UNRELIABLE_
        end
      end
      NIL_
    end
  end
# ->
  end
end
