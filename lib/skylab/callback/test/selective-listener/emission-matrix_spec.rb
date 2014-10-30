require_relative 'test-support'

module Skylab::Callback::TestSupport::Selective_Listener

  describe "[cb] selective listener - emission matrix" do

    extend TS__

    before :all do

      class Goofis_EM

        Subject_.call self,
          :emission_matrix, [ :inf, :err ], [ :ln, :str ]

        def initialize listener
          @listener = listener
        end
      end

      class Listener_EM
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
      @a.should eql %i( inf str I_S err ln E_L )
    end

    def build_listener
      Listener_EM.new( @a = [] )
    end

    def build_subject
      Goofis_EM.new listener
    end
  end
end
