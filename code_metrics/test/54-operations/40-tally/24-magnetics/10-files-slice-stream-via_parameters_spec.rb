require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - magnetics - files slice stream" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :operations_tally_magnetics

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
          expect( r ).to be_include chunk.length
          chunk.each do | path |
            h[ ::File.basename( path ) ] = true
          end
        end
        h[ 'cli.rb' ] or fail
        h[ 'files-slice-stream-via-parameters.rb' ] or fail
      end

      it "emitted the event talkin bout not found" do

        em_a = _state.emissions

        expect( em_a.length ).to eql 1

        em = em_a.fetch 0

        expect( em.channel_symbol_array.last ).to eql :from_find

        _ = "find: -egads-not-a-path-nor-an-operator: No such file or directory\n"

        _act = em.to_black_and_white_line

        _act == _ || fail
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
        expect( a.length ).to eql 1
        expect( a.last.length ).to eql 1
        expect( ::File.basename a.last.last ).to eql 'hey.code'
      end

      it "no events" do
        expect( _state.emissions.length ).to be_zero
      end
    end

    def _state_me o
      _st = o.execute
      _a = _st.to_a
      _State.new _a, __flush_emissions
    end

    dangerous_memoize :_State do
      Models_4_2_1_Struct = ::Struct.new :a, :emissions
    end

    def __flush_emissions

      el = @event_log
      @event_log = :_spent_
      a = []
      begin
        em = el.gets
        em or break
        a.push em
        redo
      end while nil
      a.freeze
    end
  end
end
