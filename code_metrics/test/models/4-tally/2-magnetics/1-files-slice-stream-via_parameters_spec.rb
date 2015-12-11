require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - 2 - 1: files slice stream" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :models_tally_magnetics

    it "loads" do
      files_slice_stream_session_class_
    end

    context "two extensions, two asset paths, one bad path" do

      shared_subject :_state do

        o = begin_files_slice_stream_session_

        eek = the_asset_directory_for_this_project_
        _one = ::File.join eek, 'magnetics-'
        _two = '-egads-not-a-path-nor-an-operator'
        _three = ::File.join eek, 'modalities'

        o.paths = [ _one, _two, _three ]

        o.name_patterns = %w( cli.rb *slice*-via-parameters.rb core.rb *.wazoozle )

        _state_me o
      end

      it "matched some files" do
        h = {}
        r = 1 .. 2
        _state.a.each do | chunk |
          r.should be_include chunk.length
          chunk.each do | path |
            h[ ::File.basename( path ) ] = true
          end
        end
        h[ 'cli.rb' ] or fail
        h[ 'files-slice-stream-via-parameters.rb' ] or fail
      end

      it "emitted the event talkin bout not found" do

        # do this differently at [#ca-065]

        _state.events.length.should eql 1

        ev = _state.events.fetch 0

        ev.terminal_channel_i.should eql :from_find

        ev.ok.should be_nil

        _ = "find: -egads-not-a-path-nor-an-operator: No such file or directory\n"

        black_and_white( ev ).should eql _
      end
    end

    context "ignore two path patterns" do

      shared_subject :_state do

        o = begin_files_slice_stream_session_

        o.ignore_paths = %w( *ixture-files-on* */hi.code )

        o.paths = [ Fixture_tree_directory_[] ]

        _state_me o
      end

      it "the expected files match" do
        a = _state.a
        a.length.should eql 1
        a.last.length.should eql 1
        ::File.basename( a.last.last ).should eql 'hey.code'
      end

      it "no events" do
        _state.events.should be_nil
      end
    end

    def _state_me o
      _st = o.execute
      _a = _st.to_a
      _State.new _a, __flush_events
    end

    dangerous_memoize :_State do
      Models_4_2_1_Struct = ::Struct.new :a, :events
    end

    def __flush_events
      # this will change at [#ca-065]
      x = @ev_a
      @ev_a = nil
      x.freeze
    end
  end
end
