require_relative 'test-support'

module Skylab::Basic::TestSupport::Tree

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Basic::Tree } asks - what if trees were functional?" do

    it "enumerator tree" do

      tree = Basic::Tree.new :local_data_1 do |y|

        y << :node_1

        y << Basic::Tree.new do |yy|

          yy << :node_2_1

          yy << ( Basic::Tree.new :local_data_3 do |yyy|
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
  end
end
