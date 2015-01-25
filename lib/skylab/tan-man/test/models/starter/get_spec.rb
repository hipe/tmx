require_relative 'test-support'


module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter get" do

    extend TS_

    it "'workspace_path' is required (currently)" do
      call_API :starter, :get
      expect_event :missing_required_properties do |ev|
        ev.to_event.miss_a.first.name_i.should eql :path
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
          :value_fetcher, :_not_quite_to_here_,
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
          +[ starter "digraph.dot" ]
        O

        call_API :starter, :lines,
          :value_fetcher, get_value_fetcher,
          :workspace_path, @ws_pn.to_path, :config_filename, cfn
        scn = @result

        d = 0
        io = _IO_spy

        while line = scn.gets
          d += line.length
          io.puts line
        end

        ( 80 .. 1000 ).should be_include d  # the number of bytes written

        io.string[ 0, 32  ].should eql "# created by tan-man on CRTD ON\n"

        expect_no_events

      end
    end

    def get_value_fetcher
      bx = TanMan_::Callback_::Box.new
      bx.add :created_on, 'CRTD ON'
      bx
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
