require_relative 'test-support'

module ::Skylab::PubSub::TestSupport::Emitter

  describe "#{Skylab::PubSub::Emitter} Crazy Graphs:" do
    extend ::Skylab::PubSub::TestSupport::Emitter

    context "class Gamma extends mod Alpha which defines a graph" do
      modul :Alpha do
        extend PubSub::Emitter
        emits :alpha
      end
      klass :Gamma do |o|
        extend PubSub::Emitter::ModuleMethods
        include o.Alpha
      end

      it "works" do
        g = _Gamma.new
        g.emit :alpha, nil # does not raise
        ->{ g.emit :no, nil }.should raise_error(
          'undeclared event type :no for Gamma' )
      end
    end

    context "class D extends G which includes B which includes A which etc" do
      modul :Alpha do
        extend PubSub::Emitter
        emits :alpha
      end
      modul :Beta do |o|
        include o.Alpha
      end
      klass :Gamma do |o|
        extend PubSub::Emitter::ModuleMethods
        include o.Beta
      end
      klass :Delta, extends: :Gamma

      it "works" do
        d = _Delta.new
        d.emit :alpha, nil
        ->{ d.emit :no, nil }.should raise_error(
          'undeclared event type :no for Delta' )
      end
    end
  end
end
