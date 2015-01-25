require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  describe "[tm] models - meaning - list" do

    extend TS_

    it "C-style" do

      call_API :meaning, :ls, :input_string, "digraph{/* foo : fee \n fiffle: faffle */}"

      expect_no_events
      st = @result

      ent = st.gets
        ent.natural_key_string.should eql 'foo'
        ent.value_string.should eql 'fee '

      ent = st.gets
        ent.natural_key_string.should eql 'fiffle'
        ent.value_string.should eql 'faffle */'  # <- LOOK

      st.gets.should be_nil

    end

    it "shell-style" do

      _input_string = <<-O.unindent
        digraph {
          # money : honey
          # funny : bunny
        }
      O

      call_API :meaning, :ls, :input_string, _input_string

      st = @result
      ent = st.gets
        ent.natural_key_string.should eql 'money'
        ent.value_string.should eql 'honey'

      ent = st.gets
        ent.natural_key_string.should eql 'funny'
        ent.value_string.should eql 'bunny'

      st.gets.should be_nil
    end

    it "when input does not parse as a graph-viz dotfile (it borks)"
  end
end
