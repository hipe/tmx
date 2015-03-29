require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  describe "[st] models - tree - expad - text - classified stream from paths" do

    extend TS_

    it "3 node triangle" do

      tree = fp 'a/b', 'a/c'
      tree = tree.fetch_only_child

      st = tree.to_classified_stream_for :text

      y = []

      begin
        card = st.gets
        card or break
        y.push "#{ card.prefix_string }#{ card.node.any_slug }\n"
        redo
      end while nil

      _exp = deindent <<-HERE
        a
         ├b
         └c
      HERE

       y.join( EMPTY_S_ ).should eql _exp
    end

    it "3 point beanstalk" do

      tree = fp 'a/b/c'
      tree = tree.fetch_only_child
      st = tree.to_classified_stream_for :text
      y = []

      begin
        card = st.gets
        card or break
        y.push "#{ card.prefix_string }#{ card.node.any_slug }\n"
        redo
      end while nil

      _exp = deindent <<-HERE
        a
         └b
           └c
      HERE

      y.join( EMPTY_S_ ).should eql _exp
    end

    it "vertical runs" do

      tree = fp 'z/hufflbuff/ravendoor',
        'z/hufflbuff/ravendoor/sabblewood',
        'z/snaggoletoogh/liverwords',
        'z/snaggoletoogh/liverwords/beef',
        'z/snaggoletoogh/jonkerknocker',
        'z/hufflebuff/nikclebonkers',
        'z/jipsaw'

      tree = tree.fetch_only_child
      st = tree.to_classified_stream_for :text

      y = []
      begin
        cx = st.gets
        cx or break
        y.push "#{ cx.prefix_string }#{ cx.node.slug }\n"
        redo
      end while nil

      _exp = deindent( <<-HERE )
        z
         ├hufflbuff
         │ └ravendoor
         │   └sabblewood
         ├snaggoletoogh
         │ ├liverwords
         │ │ └beef
         │ └jonkerknocker
         ├hufflebuff
         │ └nikclebonkers
         └jipsaw
       HERE

       y.join( EMPTY_S_ ).should eql _exp
    end
  end
end
