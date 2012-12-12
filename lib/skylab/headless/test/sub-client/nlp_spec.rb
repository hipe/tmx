require_relative 'test-support'

module ::Skylab::Headless::TestSupport::SubClient


  describe "#{ Headless::SubClient } NLP" do
    extend SubClient_TestSupport

    it "looks great" do

      o = ::Object.new
      o.extend Headless::SubClient::InstanceMethods
      x = nil
      o.instance_exec do
        a = ['A', 'B']
        n = a.length
        x = "#{ s a, :no }known person#{ s } #{ s :is } #{
          }#{ and_ a }".strip
        x << " in #{ s :this }#{" #{ n }" unless 1 == n }#{
          } location#{ s }."
      end
      x.should eql('known persons are A and B in these 2 locations.')
    end
  end
end
