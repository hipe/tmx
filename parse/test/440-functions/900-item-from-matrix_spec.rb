require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - item from matrix" do

    TS_[ self ]
    use :expect_event

    define_singleton_method :memoize_ do | sym, & p |

      define_method sym, Common_::Memoize[ & p ]
    end

    context "(against first grammar)" do

      it "find the longest whole match, skipping over the shorter one" do

        in_st = input_stream_via_array %w( bilbo baggins daggins waggins )

        _go( in_st ).value.should eql :__bilbo_baggins__

        in_st.current_index.should eql 2
      end

      it "with no input, event that describes it as the end of the input" do

        in_st = the_empty_input_stream

        _go( in_st, & handle_event_selectively_ ).should eql false

        _ev = _expect_common_event
        black_and_white( _ev ).should eql( _at_end_expecting 'frodo', 'bilbo' )
      end

      it "with input whose head matches multiple items but only fully matches one" do

        in_st = input_stream_via_array %w( bilbo dazoink )

        _go( in_st, & handle_event_selectively_ ).value.should eql :__bilbo__

        in_st.current_index.should eql 1
      end

      it "a partial match gets you nothing (strange token)" do

        in_st = input_stream_via_array %w( frodo nodo )

        _go( in_st, & handle_event_selectively_ ).should eql false

        ev = _expect_common_event

        black_and_white( ev ).should eql(
          "#{ _uninterpretable 'nodo' }#{ _expecting 'baggins' }" )

        ev.token.should eql 'nodo'
        a = ev.item_stream_proc.call.to_a
        a.length.should eql 1
        a.first.value.should eql :__frodo_baggins__

        in_st.current_index.should eql 0
      end

      it "a partial match gets you nothing (end of input)" do

        in_st = input_stream_via_array %w( frodo )

        _go( in_st, & handle_event_selectively_ ).should eql false

        black_and_white( _expect_common_event ).should eql(
          _at_end_expecting 'baggins' )

        in_st.current_index.should be_zero
      end

      it "a strange token at the beginning" do

        in_st = input_stream_via_array %w( nodo )

        _go( in_st, & handle_event_selectively_ ).should eql false

        black_and_white( _expect_common_event ).should eql(
          "#{ _uninterpretable 'nodo' }#{ _expecting 'frodo', 'bilbo' }" )

        in_st.current_index.should be_zero
      end

      memoize_ :_subject_f do

        _build_function_against_matrix(
          %w( frodo baggins ),
          %w( bilbo ),
          %w( bilbo wilbo ),
          %w( bilbo baggins chauncerly ),
          %w( bilbo baggins ) )
      end
    end

    context "(against second grammar)" do

      it "backtracks to last full match" do

        in_st = input_stream_via_array %w( ohai elizabeth keen
          tom keen raymond reddington HEADdington )

        in_st.advance_one

        _go( in_st ).value.should eql :__elizabeth_keen_tom_keen__

        in_st.current_index.should eql 5
      end

      memoize_ :_subject_f do

        _build_function_against_matrix(
          %w( elizabeth keen ),
          %w( elizabeth keen tom keen ),
          %w( elizabeth keen tom keen raymond reddington feddington ) )
      end
    end

    context "(against third grammar)" do

      it "edge case" do

        in_st = input_stream_via_array %w( xx yy )

        _go( in_st, & handle_event_selectively_ ).value.should(
          eql :__xx_yy__ )

        in_st.current_index.should eql 2
      end

      memoize_ :_subject_f do

        _build_function_against_matrix(
          %w( xx yy ) )
      end
    end

    it "you can build it with a proc that produces the stream" do

      _o = self.class._function_class.via_item_stream_proc do
        self.class._build_item_stream_via_string_matrix [ [ 'a', 'b' ] ]
      end

      _st = _o.instance_variable_get( :@item_stream_proc ).call

      _st.gets.value.should eql :__a_b__
    end

    def _go in_st, & x_p
      _subject_f.output_node_via_input_stream in_st, & x_p
    end

    def _uninterpretable s
      "uninterpretable token #{ s.inspect }. "
    end

    def _at_end_expecting * s_a
      "at end of input #{ _expecting( * s_a ) }"
    end

    def _expecting * s_a
      "expecting #{ s_a.map( & :inspect ) * ' or ' }"
    end

    class << self

      def _build_function_against_matrix * a_a

        _function_class.with(
          :item_stream_proc, -> do
            _build_item_stream_via_string_matrix a_a
          end
        )
      end

      def _build_item_stream_via_string_matrix a_a

        Common_::Stream.via_nonsparse_array a_a do | row |

          Common_::QualifiedKnownKnown.via_value_and_association(
            :"__#{ row * UNDERSCORE_ }__",
            row,
          )
        end
      end

      def _function_class
        Home_.function :item_from_matrix
      end
    end  # >>

    def _expect_common_event

      _em = expect_not_OK_event :expecting
      _em.cached_event_value
    end
  end
end
