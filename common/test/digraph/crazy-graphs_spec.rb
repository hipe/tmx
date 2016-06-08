require_relative 'test-support'

module Skylab::Callback::TestSupport::Digraph

  describe "[ca] digraph crazy graphs" do

    extend Home_::TestSupport::Digraph

    context "class Gamma extends mod Alpha which defines a graph" do  # #todo below could be etc
      modul :Alpha do
        Home_[ self, :employ_DSL_for_digraph_emitter ]
        listeners_digraph :alpha
        public :call_digraph_listeners # [#002] public for testing
      end
      klass :Gamma do |o|
        Home_[ self, :extend_digraph_emitter_module_methods ]
        include o.Alpha
      end

      it "works" do
        g = _Gamma.new
        g.call_digraph_listeners :alpha, nil # does not raise
        ->{ g.call_digraph_listeners :no, nil }.should raise_error(
          'undeclared event type :no for Gamma' )
      end
    end

    context "class D extends G which includes B which includes A which etc" do
      modul :Alpha do
        Home_[ self, :employ_DSL_for_digraph_emitter ]
        listeners_digraph :alpha
        public :call_digraph_listeners # [#002] public for testing
      end
      modul :Beta do |o|
        include o.Alpha
      end
      klass :Gamma do |o|
        Home_[ self, :extend_digraph_emitter_module_methods ]
        include o.Beta
      end
      klass :Delta, extends: :Gamma

      it "works" do
        d = _Delta.new
        d.call_digraph_listeners :alpha, nil
        ->{ d.call_digraph_listeners :no, nil }.should raise_error(
          'undeclared event type :no for Delta' )
      end
    end
  end
end
