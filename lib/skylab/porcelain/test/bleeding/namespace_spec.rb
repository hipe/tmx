require_relative '../../core'
require_relative 'test-support'


module ::Skylab::Porcelain::Bleeding::TestSupport
  class MyAction
    extend Bleeding::Action
  end
  describe "#{Bleeding::Namespace} resolving names" do
    include Porcelain::TiteColor # unstylize
    extend ::Skylab::MetaHell::ModulCreator
    let(:base_module) { Module.new }
    let(:err) { ->(o) { o.on_error { |e| rt.emit(e) } } }
    let(:find) { self.MyActions.build(rt).find(token, &err) }
    let(:rt) do
      ::Skylab::TestSupport::EmitSpy.new { |e| "#{e.type.inspect}<-->#{e.message.inspect}" } # add debug!
    end
    let(:subject) do
      find
      rt.stack.map { |e| SimplifiedEvent.new(e.type, unstylize(e.message)) } # ick
    end
    context "among none" do
      modul :MyActions do
        extend Bleeding::Namespace
      end
      context "with none given" do
        let(:token) { nil }
        specify { should be_event(:not_provided, 'expecting {}') }
      end
      context "with one given" do
        let(:token) { 'herkemer' }
        specify { should be_event(:not_found, 'invalid command "herkemer". expecting {}') }
      end
    end
    context "among one" do
      modul :MyActions do
        extend Bleeding::Namespace
        class self::Ferp
          extend Bleeding::Action
        end
      end
      context "with none given" do
        let(:token) { nil }
        specify { should be_event(:not_provided, "expecting {ferp}") }
      end
      context "with a correct one given" do
        let(:token) { 'ferp' }
        let(:subject) { find }
        specify { should eql(self.MyActions::Ferp) }
      end
      context "with a partial match given" do
        let(:token) { 'fe' }
        let(:subject) { find }
        specify { should eql(self.MyActions::Ferp) }
      end
      context "with an incorrect one given" do
        let(:token) { 'fo' }
        specify { should be_event(:not_found, 'invalid command "fo". expecting {ferp}') }
      end
    end
    context "among two" do
      modul :MyActions do
        extend Bleeding::Namespace
        class self::Derpa < MyAction ; end
        class self::Derka < MyAction ; end
      end
      context "with none given" do
        let(:token) { nil }
        specify { should be_event(:not_provided, 'expecting {derpa|derka}') }
      end
      context "with a wrong one given" do
        let(:token) { 'hoik' }
        specify { should be_event(/invalid command "hoik".*expecting/i) }
      end
      context "with an ambiguous partial match given" do
        let(:token) { 'der' }
        specify { should be_event('ambiguous comand "der". did you mean derpa or derka?') }
      end
      context "with an umambiguous partial match given" do
        let(:token) { 'derp' }
        let(:subject) { find }
        specify { should eql(self.MyActions::Derpa) }
      end
      context "with a whole match given" do
        let(:token) { 'derka' }
        let(:subject) { find }
        specify { should eql(self.MyActions::Derka) }
      end
    end
  end
end
