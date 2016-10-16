require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - association delete" do

    TS_[ self ]
    use :models_association

    it "remove when first node not found (no stmt_list)" do
      call_API_against "digraph {\n}\n"
      expect_not_OK_event :no_stmt_list
      expect_empty_output
      expect_failed
    end

    it "remove when first node not found" do
      call_API_against "digraph {\nbaz}\n"
      expect_not_OK_event :node_not_found, 'node not found - (ick "foo")'
      expect_empty_output
      expect_failed
    end

    it "remove when 2nd node not found" do
      call_API_against "digraph {\n foo [ label = \"foo\"]\n }\n"
      expect_not_OK_event :node_not_found, 'node not found - (ick "bar")'
      expect_empty_output
      expect_failed
    end

    it "remove when not associated" do
      call_API_against "digraph {\n foo\nbar\nbar -> foo\n }\n"
      expect_not_OK_event :component_not_found,
        'association not found - (code "foo -> bar")'
      expect_empty_output
      expect_failed
    end

    it "remove when associated" do
      call_API_against "digraph {\n foo\nbar\nfoo -> bar\n }\n"
      expect_OK_event :deleted_association do |ev|
        ev.to_event.association.unparse.should eql "foo -> bar"
      end
      @output_s.should eql "digraph {\n foo\nbar\n}\n"
      expect_event :wrote_resource
      expect_succeeded
    end

    def expect_empty_output
      @output_s.should eql EMPTY_S_
    end

    def call_API_against inp_s
      @output_s = ::String.new
      call_API :association, :rm,
        :input_string, inp_s, :output_string, @output_s,
        :from_node_label, 'foo', :to_node_label, 'bar'
    end
  end
end
