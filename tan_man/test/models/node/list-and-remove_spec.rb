require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Node

  describe "[tm] node list and remove" do

    extend TS_

    it "a workspace without a graph value complains & invite" do

      call_API :node, :ls,
        :workspace_path, dir( :with_freshly_initted_conf ),
        :config_filename, 'tan-man.conf'

      ev = expect_not_OK_event :property_not_found

      ev.to_event.invite_to_action.should eql [ :graph, :use ]

      ev.to_event.property_symbol.should eql :graph

      expect_failed
    end

    it "`list` results in a stream of entities. see node label with 'name' prop" do

      call_API :node, :ls,
        :workspace_path, dir( :two_nodes ),
        :config_filename, cfn_shallow

      st = @result

      x = st.gets
      x.property_value_via_symbol( :name ).should eql 'foo'

      x = st.gets
      x.property_value_via_symbol( :name ).should eql 'bar'

      st.gets.should be_nil
    end

    it "remove nope" do

      call_API :node, :rm,
        :name, 'berk',
        :workspace_path, dir( :two_nodes ),
        :config_filename, cfn_shallow

      ev = expect_neutral_event :component_not_found
      ev.to_event.entity_name_string.should eql 'berk'
      expect_failed
    end

    it "remove money" do

      using_dotfile <<-O.unindent
        digraph {
          ermagherd [ label = "berks" ]
        }
      O

      call_API :node, :rm,
        :name, 'berks',
        :workspace_path, @workspace_path,
        :config_filename, cfn_shallow

      ev = expect_OK_event( :wrote_resource ).to_event
      ev.is_completion.should eql true
      ev.bytes.should eql 14

      expect_no_more_events
    end
  end
end
