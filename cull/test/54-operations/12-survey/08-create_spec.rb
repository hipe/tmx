require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - create" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

# (1/N)
    it "loads" do
      Home_::API
    end

    context "ping the top" do

      # (we're not supposed to do this but we're structuring this one
      # test in the newer style but still using the older library) :#history-A.1

      it "modality-specific styled message comes through" do

        want_these_lines_in_array_ _tuple.first do |y|

          y << "the 'ping' action of cull says *hello*!"
        end
      end

      it "result is result" do
        _tuple.last == :hello_from_cull || fail
      end

      shared_subject :_tuple do

        _p = event_log.handle_event_selectively

        x = Home_::API.call(
          :ping,
          :some_word, "bazoozle",
          & _p )

        a = []
        want_emission :info, :expression, :ping do |y|
          a.push y
        end
        want_no_more_events

        a.push x
      end
    end

# (2/N)
    it "ping the model node" do
      call_API :survey, :ping
      want_OK_event :ping, 'cull says *hello*'
      want_no_more_events
      @result.should eql :_hi_again_
    end

# (3/N)
    it "create on a directory with the thing already" do
        _path = freshly_initted_path_
        call_API(
          * _subject_action,
          :path, _path,
        )
      want_not_OK_event :directory_exists
      want_fail
    end

# (4/N)
    it "go money" do

        _path = prepare_tmpdir.to_path

        call_API(
          * _subject_action,
          :path, _path,
        )

      em = @result
      want_neutral_event :creating_directory
      want_OK_event_ :collection_resource_committed_changes

      em.category.should eql [ :info, :created_survey ]

      ev = em.emission_value_proc.call
      ev.ok or fail
      ev.path or fail
      ev.is_completion or fail
    end

    # ==

    def _subject_action
      [ :survey, :create ]
    end

    # ==
    # ==
  end
end
# #history-A.1 rewrite 1 test (no reason to keep except posterity and 1x place)
