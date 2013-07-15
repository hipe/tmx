# encoding: utf-8

require_relative 'test-support'

module Skylab::Porcelain::TestNamespace
  # (above line left intact for posterity)

  describe Porcelain::Tree do
    it "renders a pretty tree" do
      node = Porcelain::Tree.from :hash,
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

      exp = <<-HERE.gsub %r|^        |, ''
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
      act = node.to_text
      act.should eql( exp ) # use this form with --diff option
    end
  end
end
