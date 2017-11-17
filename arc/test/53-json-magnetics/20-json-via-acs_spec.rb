require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] JSON magnetics - via ACS" do

    TS_[ self ]
    use :JSON_magnetics_lite

    it "non-sparse one-level structure" do

      sn = const_( :Simple_Name ).new_cold_root_ACS_for_want_root_ACS
      sn.first_name = "\"spike\""
      sn.last_name = "jonez"

      _s = _to_json sn
      _h = ::JSON.parse _s, symbolize_names: true
      _h.should eql( first_name: '"spike"', last_name: 'jonez' )
    end

    it "with sparse structres it does NOT render nil" do

      sn = const_( :Simple_Name ).new_cold_root_ACS_for_want_root_ACS
      sn.last_name = "gustav"

      _s = _to_json_not_pretty sn
      _s.should eql '{"last_name":"gustav"}'
    end

    it "two levels ..?" do

      sn = const_( :Simple_Name ).new_cold_root_ACS_for_want_root_ACS
      sn.first_name = "FN"
      sn.last_name = "LN"

      cn = const_( :Credits_Name ).new_cold_root_ACS_for_want_root_ACS
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

      o = Home_::JSON_Magnetics::JSON_via_ACS.new
      o.customization_structure_x = nil
      o.upstream_ACS = sn
      o
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_01_Names ]
    end
  end
end
