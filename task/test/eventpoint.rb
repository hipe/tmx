module Skylab::Task::TestSupport

  module Eventpoint

    def self.[] tcc
      tcc.include self
    end

    # -

    if false
    def recon from_i, to_i, sig_a
      possible_graph.reconcile y, from_i, to_i, sig_a
    end

    def recon_plus from_i, to_i, sig_a

      o = possible_graph.build_reconciliation y, from_i, to_i, sig_a

      wv = o.work_

      # (we are translating back to the old "pair" style for legacy tests)

      if wv
        [ true, wv.value_x ]
      else
        [ wv, o.expression_grid ]
      end
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

    def subject_
      Eventpoint_Namespace::Subject
    end
    end
      def subject_module_
        Home_::Eventpoint
      end

    # -
  end
end
