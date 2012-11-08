require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Klass::Creator
  describe "#{MetaHell::Klass::Creator::InstanceMethods}" do
    extend Creator_TestSupport

    context "minimal" do
      snip
      it "zeep" do
        k = o.klass! :Feep
        k.should be_kind_of(::Class)
        k.to_s.should eql('Feep')
        k.instance_methods(false).should eql([])
        k.object_id.should eql((o.klass! :Feep).object_id)
        k.ancestors[1].should eql(::Object)
      end
    end


    it "try to manipulate as a class s/thing you started as a module"

    it "show that it autovivifies modules, but go bakc and etc"
  end
end
