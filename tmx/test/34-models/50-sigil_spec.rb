require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] models - sigil" do

    it "the result knows the length of the longest thing string" do

      _d = _result.length_of_longest_entry_string
      _d == 18 || fail
    end

    it "the items that had names 2 or 3 letters long are all as-is" do
      _these %w(
        arc arc
        cm cm
        git git
        tmx tmx
      )
      # 4
    end

    it "the items that are multi. pieces long (not with number) are acronymized" do
      _these %w(
        beauty_salon bs
        css_convert cc
        doc_test dt
        git_viz gv
        search_and_replace sar
        sub_tree st
        tan_man tm
        task_examples te
        test_support ts
      )
      # 9
    end

    it "this one needed special handing to avoid an already taken name" do
      _these %w(
        code_metrics cme
      )
      # 1
    end

    it "the items that are multi. pieces long (yes number) are acronymized" do
      _these %w(
        bnf2treetop b2t
        flex2treetop f2t
        yacc2treetop y2t
      )
      # 3
    end

    it "these boring ones are boring" do
      _these %w(
        basic ba
        brazen br
        common co
        cull cu
        fields fi
        human hu
        myterm my
        parse pa
        permute pe
        plugin pl
        slicer sl
        snag sn
        system sy
        treemap tr
        zerk ze
      )
      # 15
    end

    it "but note we had to tiebreak these two" do
      _these %w(
        tabular tab
        task tas
      )
      # 2
    end

    def _these s_a

      idx = _this_index
      d = -2
      last = s_a.length - 2
      while last != d
        d += 2
        before = s_a.fetch d
        after = s_a.fetch d + 1
        actual = idx.fetch before
        actual == after || fail
      end
    end

    -> do
      x = nil ; once = -> me do
        once = nil
        rslt = me._result
        items = rslt.instance_variable_get :@items
        sigils = rslt.instance_variable_get :@sigils
        h = {}
        items.each_with_index do |my_item, d|
          h[ my_item.entry_string ] = sigils.fetch d
        end
        x = h.freeze ; nil
      end
      define_method :_this_index do
        once && once[ self ]
        x
      end
    end.call

    -> do
      x = nil ; once = -> me do
        once = nil
        _long_list = me._this_one_long_list
        _ = ::Skylab::Common::Stream.via_nonsparse_array( _long_list ).map_by do |s|
          X_ms_EekWrap.new s
        end
        x = me._subject_module.via_stemish_stream( _ ) ; nil
      end
      define_method :_result do
        once && once[ self ]
        x
      end
    end.call

    # the below "long list" is a snapshot of every current sidesystem at
    # writing. this is *exactly* how the below "long list" was generated:
    #
    #   1) find . -type f -depth 2 -name scooby-doo | cut -d/ -f 2
    #
    #      (you have to substitute whatever is the value of
    #      ::Skylab::TM::METADATA_FILENAME for "scooby-doo".)
    #
    #   2) manually add one certain sidesystem that is in development
    #      in a different branch at writing (choreo massive).

    -> do
      a = %w(
        arc
        basic
        beauty_salon
        bnf2treetop
        brazen
        code_metrics
        common
        cm
        css_convert
        cull
        doc_test
        fields
        flex2treetop
        git
        git_viz
        human
        myterm
        parse
        permute
        plugin
        search_and_replace
        slicer
        snag
        sub_tree
        system
        tabular
        tan_man
        task
        task_examples
        test_support
        tmx
        treemap
        yacc2treetop
        zerk
      ).freeze

      34 == a.length || update_me

      define_method :_this_one_long_list do
        a
      end
    end.call

    def _subject_module
      ::Skylab::TMX::Models::Sigil
    end

    class X_ms_EekWrap
      def initialize s
        @entry_string = s
      end
      attr_reader :entry_string
    end
  end
end
# #history-A: at this commit we changed this from standalone style
