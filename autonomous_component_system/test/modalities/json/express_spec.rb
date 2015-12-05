require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - JSON - express" do

    extend TS_
    use :support

    it "non-sparse one-level structure" do

      sn = const_( :Simple_Name ).new_empty_for_test_
      sn.first_name = "\"spike\""
      sn.last_name = "jonez"

      _s = _to_json sn
      _h = ::JSON.parse _s, symbolize_names: true
      _h.should eql( first_name: '"spike"', last_name: 'jonez' )
    end

    it "with sparse structres it does NOT render nil" do

      sn = const_( :Simple_Name ).new_empty_for_test_
      sn.last_name = "gustav"

      _s = _to_json_not_pretty sn
      _s.should eql '{"last_name":"gustav"}'
    end

    it "two levels ..?" do

      sn = const_( :Simple_Name ).new_empty_for_test_
      sn.first_name = "FN"
      sn.last_name = "LN"

      cn = const_( :Credits_Name ).new_empty_for_test_
      cn.simple_name = sn
      cn.nickname = "NN"

      _s = _to_json_not_pretty cn
      _s.should eql '{"nickname":"NN","simple_name":{"first_name":"FN","last_name":"LN"}}'
    end

    def _to_json sn

      _begin_to_json( sn ).build_string
    end

    def _to_json_not_pretty sn
      o = _begin_to_json sn
      o.be_pretty = false
      o.build_string
    end

    def _begin_to_json sn

      o = subject_::Modalities::JSON::Express.new
      o.upstream_ACS = sn
      o
    end
  end
end
