# encoding: utf-8

require File.expand_path('../../tree', __FILE__)

module Skylab::Porcelain::TestNamespace
  module ArrayExtension
    class << self
      def extend_to el
        el.extend self
        el.children and el.children.each do |_el|
          extend_to _el
        end
        el
      end
      alias_method :[], :extend_to
    end
    def name     ; self[:name] end
    def children ; self[:children] end
    def children?; !! self[:children] end
  end
end

module Skylab::Porcelain::TestNamespace
  include Skylab::Porcelain
  describe Tree do
    it "renders a pretty tree" do
      foo = ArrayExtension[
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
      ]
      output = subject.text foo
      DERP = <<-HERE.gsub(/^        /, '')
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
      output.should == DERP # use this form with --diff option
    end
  end
end

