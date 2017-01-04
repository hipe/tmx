require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - operation dependency customization" do

    TS_[ self ]
    use :my_API

    context "(essentials)" do

      it "loads" do
        subject_root_ACS_class
      end
    end

    context "(ok context)" do

      call_by do
        call :ounces_of_water, 12, :instant_coffee
      end

      it "ok." do
        _ = root_ACS_result
        _ == "(coffee via (boiling 12 oz of H20 at 100˚))" or fail
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_50_Dep_Graphs ]::Subnode_02_LA_LA
    end
  end
end
