require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - path stream via mondrian request" do

    TS_[ self ]
    use :memoizer_methods
    use :mondrian_lowlevel

    it "loads" do
      _subject
    end

    context "one path, nothing else" do

      given_request do |o|
        o.paths = %w( /jimmy/jammy )
      end

      it "the one path" do
        __expect_paths do |y|
          y << '/jimmy/jammy'
        end
      end
    end

    context "two glob-likes and one path" do

      same_03 = 'tree-03-gemish'

      given_request do |o|

        _ = doc_test_fixtures

        pather = _.fixture_tree_pather same_03

        o.paths = [
          pather[ 'lib/zerby-derby/**/*[a-z]-[fr]*.ko' ],
          pather[ 'no-ent.hi' ],
          pather[ 'test/**/cerebus*' ],
        ]
      end

      it "the multiple items of a single glob expand into multiple paths" do
        _custom_tuple.fetch( 0 ) == 2  || fail  # this_count
      end

      it "the order that the groups are flattened into is user order" do

        actual_order = _custom_tuple.fetch(1)  # what_order

        2 <= actual_order.length || fail
          # (is the sort working? if only 2 groups, low confidence..)

        expected_order = actual_order.sort
        actual_order == expected_order || fail
      end

      it "even a no-ent path can sneak thru (as a plain path)" do
        _custom_tuple.fetch(2) || fail  # saw_this_noent
      end

      shared_subject :_custom_tuple do

        _st = build_path_stream_

        what_order = []
        first_group_happened = -> do
          first_group_happened = Home_::EMPTY_P_
          what_order.push :"1_first_group"
        end
        this_count = 0
        saw_this_noent = false

        pool = {
          'berdersic-flersic-.ko' => -> do
            this_count += 1
            first_group_happened[]
          end,
          'cerebus-rex.ko' => -> do
            this_count += 1
            first_group_happened[]
          end,
          'cerebus-rex_speg.ko' => -> do
            what_order.push :"3_second_group"
          end,
          'no-ent.hi' => -> do
            saw_this_noent = true
            what_order.push :"2_second_group"
          end,
        }

        while line = _st.gets
          basename = ::File.basename line
          p = pool.delete basename
          p or fail "unexpected file (basename) in result: #{ basename.inspect }"
          p[]
        end

        [ this_count, what_order, saw_this_noent ]
      end
    end

    def __expect_paths

      st = build_path_stream_

      _y = ::Enumerator::Yielder.new do |path|
        actual = st.gets
        if actual
          if path != actual
            fail "expected: #{ path.inspect }, had: #{ actual.inspect }"
          end
        else
          fail "expected: #{ path.inspect } at end of stream"
        end
      end
      yield _y
      extra = st.gets
      extra && fail
    end

    def build_path_stream_
      _req = build_request
      _subject[ _req ]
    end

    def _subject
      Home_::Magnetics_::PathStream_via_MondrianRequest
    end
  end
end
