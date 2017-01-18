require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - association create" do

    TS_[ self ]
    use :expect_line
    use :models_association

    it 'ping' do

      call_API :association, :add, :ping
      expect_OK_event :ping_from_action, 'ping from action - (ick :add)'
      @result.should eql :ping_from__add__
    end

    context "when input cannot be resolved" do

      it ".. because nothing provided" do
        call_API :association, :add, :from_node_label, 'A', :to_node_label, 'B'
        expect_not_OK_event :non_one_IO,
          "need exactly 1 input-related argument, had 0 #{
           }(provide (or_ [\"(par input_string)\", \"(par input_path)\", \"(par workspace_path)\"]))"
        expect_failed
      end
    end

    using_input '../fixture-dot-files-for-node/simple-prototype-and-graph-with/zero-but-with-leading-space.dot' do

      it 'associates nodes when neither exists, creating them' do

        associate 'one', 'two'

        scn = @event_log.flush_to_scanner

        _ = scn.head_as_is.channel_symbol_array.last

        if :creating == _
          scn.advance_one  # ugly fix for [#086]
        end

        @event_log = scn.flush_to_stream

        expect_OK_event :created_node, 'created node (lbl "one")'

        expect_OK_event :created_node, 'created node (lbl "two")'

        expect_OK_event :created_association, 'created association: one -> two'

        excerpt( -4 .. -1 ).should eql <<-O.unindent
          one [label=one]
          two [label=two]
          one -> two
          }
        O

        expect_succeeded
      end
    end

    using_input '2-nodes-0-edges.dot' do

      it "associates when first exists, second does not" do
        associate 'alpha', 'peanut gallery'
        expect_OK_event :found_existing_node, 'found existing node (lbl "alpha")'
        expect_OK_event :created_node
        expect_OK_event :created_association
        excerpt( -4 .. -2 ).should eql <<-O.unindent
          alpha [label=alpha]
          peanut [label="peanut gallery"]
          alpha -> peanut
        O
        expect_succeeded
      end
    end

    using_input '2-nodes-1-edge.dot' do

      it 'does not associate again redundantly' do

        associate 'alpha', 'gamma'

        scn = @event_log.flush_to_scanner

        # #hack-ignore :found_existing_node (x2), :found_existing_association

        begin
          if :document_did_not_change == scn.head_as_is.channel_symbol_array.last
            break
          end
          scn.advance_one
          redo
        end while nil

        @event_log = scn.flush_to_stream

        expect_neutral_event :document_did_not_change

        expect_neutralled
      end
    end

    using_input '0-nodes-3-edges.dot' do

      it "adds edge statements in unobtrusive lexical-esque order, #{
           } with taxonomy and proximity" do

        associate 'feasly', 'teasly'
        excerpt( -8 .. -2 ).should eql <<-O.unindent
          */
          feasly [label=feasly]
          teasly [label=teasly]
          beasly -> teasly
          feasly -> teasly
          gargoyle -> flargoyle
          ainsly -> fainsly
        O
      end
    end

    using_input 'point-5-1-prototype.dot' do

      it 'uses any edge prototype called "edge_stmt"' do
        associate 'foo', "bar's mother"
        excerpt( -2 .. -2 ).should eql(
         "foo -> bar [ penwidth = 5 fontsize = 28 fontcolor = \"black\" label = \"e\" ]\n" )
        expect_succeeded_result
      end
    end

    using_input 'point-5-2-named-prototypes.dot' do

      it "association prototype not found" do
        associate 'a', 'b', :prototype, :clancy
        expect_OK_event :created_node
        expect_OK_event :created_node
        expect_not_OK_event :association_prototypes_not_found,
          "the stmt_list has no prototype named (ick :clancy)"
        expect_failed
      end

      it "lets you choose which of several edge prototypes" do
        associate 'c', 'd', :prototype, :fancy
        associate_again 'b', 'a', :prototype, :boring
        excerpt( -7 .. -2 ).should eql <<-O.unindent
          a [label=a]
          b [label=b]
          c [label=c]
          d [label=d]
          b -> a [this=is not=fancy]
          c -> d [this=style is=fancy]
        O
      end
    end

    using_input 'point-5-1-prototype.dot' do

      it "lets you set attributes in the edge prototype (alphabeticesque)" do
        associate 'a', 'b', :attrs, { label: %<joe's mom: "jane"> }
        excerpt( -2 .. -2 ).should eql <<-O.unindent
          a -> b [ penwidth = 5 fontsize = 28 fontcolor = "black" label = "joe's mom: \\"jane\\"" ]
        O
        expect_succeeded_result
      end

      it "lets you set attributes not yet in the edge prototype" do
        associate 'a', 'b', :attrs, { politics: :radical }
        excerpt( -2 .. -2 ).should eql <<-O.unindent
          a -> b [ penwidth = 5 fontsize = 28 fontcolor = "black" label = "e" politics = radical ]
        O
        expect_succeeded_result
      end
    end

    it "against a digraph with two nodes, will first match existing nodes fuzzily before creating" do

      s = <<-HERE.unindent
        digraph {
          bar [label=bar]
          foo [label=foo]}
      HERE

      call_API :association, :add,
        :from_node_label, 'fo',
        :to_node_label, 'ba',
        :input_string, s,
        :output_string, s

      expect_OK_event :found_existing_node
      expect_OK_event :found_existing_node
      expect_OK_event :created_association
      @output_s = s
      excerpt( 3 .. 3 ).should eql "  foo -> bar}\n"
    end

    def associate src_s, tgt_s, * x_a_
      x_a = [ :association, :add ]
      add_input_arguments_to_iambic x_a
      add_output_arguments_to_iambic x_a
      x_a.push :from_node_label, src_s, :to_node_label, tgt_s
      x_a_.length.nonzero? and x_a.concat x_a_
      call_API_via_iambic x_a ; nil
    end

    def associate_again src_s, tgt_s, * x_a_
      x_a = [ :association, :add ]
      s = @output_s ; @output_s = ::String.new
      x_a.push :input_string, s
      x_a.push :output_string, @output_s
      x_a.push :from_node_label, src_s, :to_node_label, tgt_s
      x_a_.length.nonzero? and x_a.concat x_a_
      call_API_via_iambic x_a ; nil
    end

    ignore_these_events :using_parser_files, :wrote_resource
  end
end
