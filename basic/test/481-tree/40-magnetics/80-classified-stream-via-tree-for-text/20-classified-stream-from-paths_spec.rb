require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - classified stream via tree for text - paths" do

    TS_[ self ]
    use :tree

    it "3 node triangle" do

      tree = via_paths_ 'a/b', 'a/c'
      tree = tree.fetch_only_child

      st = tree.to_classified_stream_for :text

      y = []

      begin
        card = st.gets
        card or break
        y.push "#{ card.prefix_string }#{ card.node.slug }\n"
        redo
      end while nil

      _exp = deindent_ <<-HERE
        a
         ├b
         └c
      HERE

       expect( y.join( EMPTY_S_ ) ).to eql _exp
    end

    it "3 point beanstalk" do

      tree = via_paths_ 'a/b/c'
      tree = tree.fetch_only_child
      st = tree.to_classified_stream_for :text
      y = []

      begin
        card = st.gets
        card or break
        y.push "#{ card.prefix_string }#{ card.node.slug }\n"
        redo
      end while nil

      _exp = deindent_ <<-HERE
        a
         └b
           └c
      HERE

      expect( y.join( EMPTY_S_ ) ).to eql _exp
    end

    it "vertical runs" do

      tree = via_paths_ 'z/hufflbuff/ravendoor',
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

      _exp = deindent_ <<-HERE
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

       expect( y.join( EMPTY_S_ ) ).to eql _exp
    end
  end
end
