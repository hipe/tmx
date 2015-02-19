require_relative 'test-support'


module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter get" do

    extend TS_

    it "'workspace_path' is required (currently)" do
      call_API :starter, :get
      expect_event :missing_required_properties do |ev|
        ev.to_event.miss_a.first.name_symbol.should eql :workspace_path
      end
      expect_failed
    end

    it "when workspace path is illegitamate" do
      use_empty_ws
      call_API :starter, :get,
        :workspace_path, @ws_pn.join( 'xxx' ).to_path
      expect_event :start_directory_does_not_exist
      expect_failed
    end

    it "when workspace path does not have config filename" do
      use_empty_ws
      call_API :starter, :get,
        :workspace_path, @ws_pn.to_path
      expect_event :workspace_not_found
      expect_failed
    end

    it "when workspace does not have entity" do

      prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1 @@
        +[ whatever ]
      O

      call_API :starter, :get,
        :workspace_path, @ws_pn.to_path, :config_filename, cfn

      ev = expect_not_OK_event :entity_not_found
      black_and_white( ev ).should eql 'in config there are no starters'
      expect_failed
    end

    it "when workspace has multiple entities, none of which exist" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1,2 @@
        +[ starter "holodeck" ]
        +[ starter "holy-derp.dot" ]
      HERE

      call_API :starter, :get,
        :workspace_path, @ws_pn.to_path, :config_filename, cfn

      ev = expect_neutral_event :single_entity_resolved_with_ambiguity

      black_and_white( ev ).should eql(
        'in config there is more than one starter. using the last one.' )

      ent = @result
      ent.class.name_function.as_human.should eql 'starter'
      ent.natural_key_string.should eql 'holy-derp.dot'

    end

    context "apply -" do

      it "go to it - when file does not exist" do

        prepare_ws_tmpdir <<-O.unindent
          --- /dev/null
          +++ a/#{ cfn }
          @@ -0,0 +1 @@
          +[ starter "digraphie" ]
        O

        call_API :starter, :lines,
          :workspace_path, @ws_pn.to_path, :config_filename, cfn

        scn = @result
        scn.should eql false

        ev = expect_not_OK_event :resource_not_found
        black_and_white( ev ).should eql "No such file or directory - digraphie"

        expect_no_more_events
      end

      it "go to it - when file does exists" do

        prepare_ws_tmpdir <<-O.unindent
          --- /dev/null
          +++ a/#{ cfn }
          @@ -0,0 +1 @@
          +[ starter "minimal.dot" ]
        O

        call_API :starter, :lines,
          :workspace_path, @ws_pn.to_path, :config_filename, cfn
        st = @result

        first_line = st.gets
        d = first_line.length
        line = st.gets
        while line
          d += line.length
          line = st.gets
        end

        ( 50 .. 60 ).should be_include d  # the number of bytes written

        first_line.should eql "# created by tan-man on {{ CREATED_ON }}\n"

        expect_no_events

      end
    end

    def _IO_spy
      @IO_spy ||= bld_IO_spy
    end

    def bld_IO_spy
      TestSupport_::IO.spy(
        :do_debug_proc, -> { do_debug },
        :debug_IO, debug_IO,
        :puts_map_proc, -> s do
          "« dbg: #{ s } »"  # #guillemets
        end )
    end
  end
end
