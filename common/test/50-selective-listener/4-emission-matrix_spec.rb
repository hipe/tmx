require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] selective listener - emission matrix" do

    TS_[ self ]
    use :selective_listener

    before :all do

      class X_sl_em_Goofis

        Home_::Selective_Listener.call self,
          :emission_matrix, [ :inf, :err ], [ :ln, :str ]

        def initialize listener
          @listener = listener
        end
      end

      class X_sl_em_Listener
        def initialize a
          @a = a ; nil
        end
        def maybe_receive_event * i_a, & p
          if p
            i_a.push p.call
          end
          @a.concat i_a ; nil
        end
      end
    end

    it "just a convenience thing for writing methods - o" do
      subject.instance_exec do
        emit_inf_str :I_S
        emit_err_ln :E_L
      end
      expect( @a ).to eql %i( inf str I_S err ln E_L )
    end

    def build_listener
      X_sl_em_Listener.new( @a = [] )
    end

    def build_subject
      X_sl_em_Goofis.new listener
    end
  end
end
