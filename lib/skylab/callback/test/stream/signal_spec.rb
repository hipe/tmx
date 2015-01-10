require_relative '../test-support'

module Skylab::Callback::TestSupport

  describe "[cb] scan - signals" do

    it "signals are an experimental hack halfway btwn a method and an event" do

      a = [ :A, :B, :c ]

      p = -> do
        a.shift
      end

      scan = subject.new do
        p[]
      end.with_signal_handlers :foo_bar, -> do
        p = -> { :gone }
        :_hi_
      end, :baz, -> do
        p = -> { :done }
        :_hey_
      end

      scan.gets.should eql :A
      scan.gets.should eql :B
      scan.receive_signal( :foo_bar ).should eql :_hi_
      scan.gets.should eql :gone
      scan.gets.should eql :gone
      scan.receive_signal( :baz ).should eql :_hey_
      scan.gets.should eql :done

    end

    it "name error when bad signal name" do
      _ = subject.new() { }.with_signal_handlers :x, nil
      -> do
        _.receive_signal :z
      end.should raise_error ::NameError, "no member 'z' in struct"
    end

    it "the signal handlers persist with the new scans" do

      a = [ :A, :B, :C ]

      canary = nil
      scan = subject.via_nonsparse_array( a ).with_signal_handlers(
        :foo, -> { canary = :yes } )

      scan_ = scan.map_by do |x|
        "-> #{ x } <-"
      end

      scan_.receive_signal :foo

      canary.should eql :yes
    end

    def subject
      Callback_::Stream__
    end
  end
end
