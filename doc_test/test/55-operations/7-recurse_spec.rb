require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - recurse intro" do

    TS_[ self ]
    use :fixture_files
    use :my_API
    use :mock_systems

    it "`path` is a required parameter" do

      begin
        call_API(
          :recurse,
          :filesystem, :_trueish_for_FS_,
          :system_conduit, :_trueish_for_system_,
        )
      rescue ::Skylab::Arc::MissingRequiredParameters => e
      end

      e.message.include? "'recurse' is missing required parameter 'path'" or fail
    end

    context "against noent dir" do

      call_by do

        _dir = the_noent_directory_

        call(
          :recurse,
          :path, _dir,
          :filesystem, the_real_filesystem_,
          :system_conduit, :_trueish_for_system_,
        )
      end

      it "fails" do
        fails
      end

      it "emits" do
        want_emission :error, :stat_error do |ev|
          _msg = black_and_white ev
          _msg.include? "No such file or directory -" or fail
        end
      end
    end

    context "whoopie list (test against self eek)" do

      call_by do

        _dir = sidesystem_path_

        call(
          :recurse,
          :path, _dir,
          :list, true,
          :filesystem, the_real_filesystem_,
          :system_conduit, the_real_system_,
        )
      end

      it "appears to succeed" do
        want_trueish_result
      end

      it "no unexpected emissions" do
        want_no_emissions
      end

      context "result.." do

        shared_subject :_array do

          a = root_ACS_result.to_a

          a.sort_by! do |uow|
            uow.asset_path.length
          end
          a
        end

        it "uow for probably shallower asset, test file DOES exit; is last thing" do

          uow = _array.fetch 0
          uow.asset_path || fail
          uow.test_path || fail
          uow.test_path_is_real && fail
        end

        it "uow for probably deeper asset, test file does NOT exist" do

          a = _array
          a.fetch(1).test_path_is_real || fail
          a.length == 3 || fail
        end
      end
    end

    context "system stubbed, filesystem LIVE" do

      call_by do

        _fs = the_real_filesystem_

        @_path = TestSupport_::Fixtures.tree_path_via_entry 'tree-05-gemish'

        _sc = mock_system_for_tree_03_gemish__

        call(
          :recurse,
          :asset_extname, '.ko',
          :test_filename_pattern, '*_speg.ko',
          :path, @_path,
          :filesystem, _fs,
          :system_conduit, _sc,
        ) # calls method #here
      end

      it "first - test file exists and is not versioned at all - skip" do

        _execute :first_UoW

        want_emission :info, :expression, :file_write_summary, :skipped

        want_no_emissions
      end

      it "second - test file exists and has unversioend changes - skip" do

        _execute :second_UoW

        want_emission :info, :expression, :file_write_summary, :skipped

        want_no_emissions
      end

      # tests that have portions of their names in all caps [#029] #note-5

      it "third - test file does not exist at all - CREATE.." do

        # (pre-assert, execute, cleanup, post-assert)

        path = ::File.join root_ACS_state.gemish, 'test', 'berdersic-flersic_speg.ko'
        ::File.exist? path and fail

        _execute :third_UoW

        stat = ::File.stat path
        ::File.unlink path  # manual-cleanup - do before assertions

        stat.size.zero? && fail   # we assert content elsewhere
        want_emission :info, :expression, :file_write_summary, :created
        want_no_emissions
      end

      context "fourth - test file exists but has no unversioned changes - UPDATE.." do

        shared_subject :_state do

          # (memo for pre-assert, execute, cleanup, memo for post-assert)

          o = X_ari_Struct2.new

          path = ::File.join root_ACS_state.gemish, 'test', 'cerebus-rex_speg.ko'
          o.content_before = ::File.read path

          _execute :fourth_UoW

          o.content_after = ::File.read path
          ::File.write path, o.content_before  # #manual-cleanup

          o.emission_stream = remove_instance_variable :@event_log
          o
        end

        it "emits as expected" do

          @event_log = _state.emission_stream

          want_emission :info, :expression, :file_write_summary, :updated
          want_no_emissions
        end

        it "content looks good" do

          exp = <<-HERE.unindent
            some test code 4

            # for this file we fake it to look like it has NO unversioned content
            # so it *will* get overwritten. every byte of this file is covered.
          HERE

          o = _state
          o.content_before == exp || fail  # sanity

          rx = /(?<=\n)/  # amazing that /$/ doesn't work
          s_a = exp.split rx

          s_a[ 2, 0 ] = [
            "  it \"xyzzytftt3glzdcr\" do\n",
            "    expect( 1 ).to eql 5\n",
            "  end\n",
          ]
          exp = s_a.join

          o.content_after == exp || fail
        end

        X_ari_Struct2 = ::Struct.new :content_before, :content_after, :emission_stream
      end

      def want_no_emissions  # (local "correction")
        @event_log.gets && fail
      end

      def root_ACS_state_via st, _  # called by #here

        _eek_a = remove_instance_variable( :@event_log ).release_to_mutable_array  # EXPERIMENT  # #todo

        first = st.gets
        first || fail

        second = st.gets
        second || fail

        third = st.gets
        third || fail

        fourth = st.gets
        fourth || fail

        fifth = st.gets
        fifth && fail

        # although options exist for `find` to control the ordering of the
        # results, we'd rather avoid them for now and just do it here instead:

        desired_order = %w(
          zerby-derby.ko
          acerbic--.ko
          berdersic-flersic-.ko
          cerebus-rex.ko
          gonzo-journalism.ko
        )

        uows = [ first, second, third, fourth ]

        uows.sort_by! do |uow|
          desired_order.index ::File.basename uow.asset_path or fail
        end

        X_ari_Struct.new( * uows, _eek_a, remove_instance_variable( :@_path ) )
      end

      X_ari_Struct = ::Struct.new(
        :first_UoW, :second_UoW, :third_UoW, :fourth_UoW, :eek, :gemish )

      def _execute member_sym

        state = root_ACS_state
        em_a = state.eek
        d = em_a.length
        execute_unit_of_work_ state[ member_sym ]
        r = d .. -1
        @event_log = Stream_[ em_a[ r ] ]
        em_a[ r ] = EMPTY_A_
        NIL
      end
    end

    h = { find_command_args: true }
    define_method :ignore_for_want_emission do
      h
    end
  end
end
# #tombstone: tested old enum meta-field
