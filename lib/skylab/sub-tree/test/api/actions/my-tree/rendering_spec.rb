# encoding: utf-8

require_relative 'rendering/test-support'

module ::Skylab::SubTree::TestSupport::API::Actions::My_Tree::Rendering

describe "[st] API actions my-tree" do  # historic hiccup borrow one

  extend TS_

  it "this magic example that brought it all home (the pink paper sessions)" do

    with <<-HERE
      a/b/c
      a/b/d/e
      a/f
    HERE

    makes <<-HERE
      a
      ├── b
      │   ├── c
      │   └── d
      │       └── e
      └── f
    HERE

  end

  it "disjoint trees" do

    with <<-HERE
      a/b/c
      a/b
      a/b/x/y/z
      x/y/z
    HERE

    makes <<-HERE
      a
      └── b
          ├── c
          └── x
              └── y
                  └── z
      x
      └── y
          └── z
    HERE

  end

  it "blank lines in input" do

    with <<-HERE
      a

      a
    HERE

    makes <<-HERE
      a
    HERE

  end

  it "this old lone-wolf and cub example from the predecessor" do

    with <<-HERE
      document/head
      document/body/element1/lone wolf/and cub
      document/body/element2/sub1
      document/body/element2/sub2
      document/body/element2/sub3
      document/body/element3/sub4
      document/foot
    HERE

    makes <<-HERE
      document
      ├── head
      ├── body
      │   ├── element1
      │   │   └── lone wolf
      │   │       └── and cub
      │   ├── element2
      │   │   ├── sub1
      │   │   ├── sub2
      │   │   └── sub3
      │   └── element3
      │       └── sub4
      └── foot
    HERE

  end
end  # pay one back
end
