require_relative 'test-support'

module Skylab::PubSub::TestSupport::Listener

  describe "[ps] listener emission matrix" do

    extend TS__

    before :all do

      class Goofis_EM
        PubSub::Listener[ self, :emission_matrix, %i( inf err ), %i( ln str ) ]

        def initialize listener
          @listener = listener
        end
      end

      class Listener_EM
        def initialize a
          @a = a ; nil
        end
        def call * i_a, & p
          i_a << p.call
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
