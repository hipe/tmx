# encoding: utf-8

require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  describe "[st] models - tree - expad - text = classified stream from hash" do

    extend TS_

    it "renders a pretty tree" do

      _node = Subject_[].from :hash,
        { :name => "document",
          :children => [
            { :name => "head" },
            { :name => "body",
              :children => [
                { :name => "element1",
                  :children => [
                    { :name => "lone wolf",
                      :children => [
                        { :name => 'and cub' }
                      ]
                    }
                  ]
                },
                { :name => "element2",
                  :children => [
                    { :name => "sub1" },
                    { :name => "sub2" },
                    { :name => "sub3" }
                  ]
                },
                { :name => "element3", :children => [ { :name => "sub4" } ] }
              ]
            },
            { :name => "foot" }
          ]
        }

      _exp = deindent( <<-HERE )
        document
         ├head
         ├body
         │ ├element1
         │ │ └lone wolf
         │ │   └and cub
         │ ├element2
         │ │ ├sub1
         │ │ ├sub2
         │ │ └sub3
         │ └element3
         │   └sub4
         └foot
      HERE

      y = []
      st = _node.to_classified_stream_for :text
      begin
        cx = st.gets
        cx or break
        y.push "#{ cx.prefix_string }#{ cx.node.slug }\n"
        redo
      end while nil

      _act = y.join EMPTY_S_

      _act.should eql _exp  # use this form with --diff option
    end
  end
end
# #tombstone artifact
