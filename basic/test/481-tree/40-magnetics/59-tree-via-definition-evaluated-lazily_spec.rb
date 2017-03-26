require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - tree via definition evaluated lazily" do

    TS_[ self ]
    use :tree

    it "(test)" do

      tree = _lazy_via_enumeresque :local_data_1 do |y|

        y << :node_1

        y << _lazy_via_enumeresque do |yy|

          yy << :node_2_1

          yy << ( _lazy_via_enumeresque :local_data_3 do |yyy|
            yyy << :node_3_1
            yyy << :node_3_2
          end )

          yy << :node_2_3
        end
      end

      tree.flatten.to_a.should eql( %i|
        node_1 node_2_1 node_3_1 node_3_2 node_2_3
      |)
    end

    def _lazy_via_enumeresque *a, & p
      Home_::Tree::Magnetics::Tree_via_DefinitionEvaluatedLazily.new p, a
    end
  end
end
