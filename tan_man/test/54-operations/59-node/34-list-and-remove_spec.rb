require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] node list and remove", wip: true do

    TS_[ self ]
    use :models_node

# (1/N)
    it "a workspace without a graph value complains & invite" do

      _dir = dir :with_freshly_initted_conf

      call_API :node, :ls,
        :workspace_path, _dir,
        :config_filename, 'tan-man.conf'

      ev = expect_not_OK_event( :property_not_found ).cached_event_value

      ev.to_event.invite_to_action.should eql [ :graph, :use ]

      ev.to_event.property_symbol.should eql :graph

      expect_fail
    end

# (2/N)
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

# (3/N)
    it "remove nope" do

      call_API :node, :rm,
        :name, 'berk',
        :workspace_path, dir( :two_nodes ),
        :config_filename, cfn_shallow

      _em = expect_neutral_event :component_not_found

      _em.cached_event_value.to_event.entity_name_string.should eql 'berk'

      expect_fail
    end

# (4/N)
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

      ev = expect_OK_event( :wrote_resource ).cached_event_value.to_event
      ev.is_completion.should eql true
      ev.bytes.should eql 14

      expect_no_more_events
    end
  end
end
