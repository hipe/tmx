require_relative 'test-support'


module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter get" do

    extend TS_

    it "'workspace_path' is required (currently)" do
      call_API :starter, :get
      expect_event :missing_required_properties do |ev|
        ev.miss_a.first.name_i.should eql :workspace_path
      end
      expect_failed
    end

    it "when workspace path is illegitamate" do
      prepare_ws_tmpdir
      call_API :starter, :get,
        :workspace_path, @ws_tmpdir.join( 'xxx' ).to_path
      expect_event :start_directory_does_not_exist
      expect_failed
    end

    it "when workspace path does not have config filename" do
      prepare_ws_tmpdir
      call_API :starter, :get,
        :workspace_path, @ws_tmpdir.to_path
      expect_event :resource_not_found
      expect_failed
    end

    it "when workspace does not have entity" do

      prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1 @@
        +[ whatever ]
      O

      call_API :starter, :get,
        :workspace_path, @ws_tmpdir.to_path, :config_filename, cfn

      ev = expect_not_OK_event :entity_not_found
      black_and_white( ev ).should eql 'in config there are no starters'
      expect_failed
    end

    it "when workspace has multiple entities, none of which exist" do

      prepare_ws_tmpdir <<-HERE.unindent
        --- /dev/null
        +++ b/local-conf.d/config
        @@ -0,0 +1,2 @@
        +[ starter "holodeck" ]
        +[ starter "holy-derp.dot" ]
      HERE

      call_API :starter, :get,
        :workspace_path, @ws_tmpdir.to_path, :config_filename, cfn

      ev = expect_neutral_event :single_entity_resolved_with_ambiguity

      black_and_white( ev ).should eql(
        'in config there is more than one starter. using the last one.' )

      expect_OK_event :entity do |ev_|
        ev_.entity.local_entity_identifier_string.should eql 'holy-derp.dot'
      end

      expect_succeeded
    end

    context "apply -" do

      it "go to it - when file does not exist" do

        prepare_ws_tmpdir <<-O.unindent
          --- /dev/null
          +++ a/local-conf.d/config
          @@ -0,0 +1 @@
          +[ starter "digraphie" ]
        O

        d = Subject_[].write(
          :io, :_not_yet_here_,
          :value_fetcher, :_not_quite_to_here_,
          :workspace_path, @ws_tmpdir.to_path, :config_filename, cfn,
          :event_receiver, event_receiver )

        d.should eql false

        ev = expect_not_OK_event :resource_not_found
        black_and_white( ev ).should eql "No such file or directory - digraphie"

        expect_no_more_events
      end

      it "go to it - when file does exists" do

        prepare_ws_tmpdir <<-O.unindent
          --- /dev/null
          +++ a/local-conf.d/config
          @@ -0,0 +1 @@
          +[ starter "digraph.dot" ]
        O

        io = _IO_spy

        d = Subject_[].write(
          :io, io,
          :value_fetcher, get_value_fetcher,
          :workspace_path, @ws_tmpdir.to_path, :config_filename, cfn,
          :event_receiver, event_receiver )

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

    def black_and_white ev
      ev.render_all_lines_into_under y=[], TanMan_::API.expression_agent_instance
      y.join NEWLINE_
    end

    def _IO_spy
      @IO_spy ||= bld_IO_spy
    end

    def bld_IO_spy
      TestSupport_::IO::Spy.new(
        :do_debug_proc, -> { do_debug },
        :debug_IO, debug_IO,
        :puts_map_proc, -> s do
          "« dbg: #{ s } »"  # #guillemets
        end )
    end

    Subject_ = TanMan_::Callback_.memoize do
      TanMan_::Models_::Starter.const_get :Actions, false
      TanMan_::Models_::Starter
    end
  end
end
