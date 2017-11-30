require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - item from matrix" do

    TS_[ self ]
    use :want_event

    define_singleton_method :memoize_ do | sym, & p |

      define_method sym, Common_::Memoize[ & p ]
    end

    context "(against first grammar)" do

      it "find the longest whole match, skipping over the shorter one" do

        in_st = input_stream_via_array %w( bilbo baggins daggins waggins )

        expect( _go( in_st ).value ).to eql :__bilbo_baggins__

        expect( in_st.current_index ).to eql 2
      end

      it "with no input, event that describes it as the end of the input" do

        in_st = the_empty_input_stream

        expect( _go in_st, & handle_event_selectively_ ).to eql false

        _ev = _want_common_event
        expect( black_and_white _ev ).to eql( _at_end_expecting 'frodo', 'bilbo' )
      end

      it "with input whose head matches multiple items but only fully matches one" do

        in_st = input_stream_via_array %w( bilbo dazoink )

        expect( _go( in_st, & handle_event_selectively_ ).value ).to eql :__bilbo__

        expect( in_st.current_index ).to eql 1
      end

      it "a partial match gets you nothing (strange token)" do

        in_st = input_stream_via_array %w( frodo nodo )

        expect( _go( in_st, & handle_event_selectively_ ) ).to eql false

        ev = _want_common_event

        expect( black_and_white( ev ) ).to eql(
          "#{ _uninterpretable 'nodo' }#{ _expecting 'baggins' }" )

        expect( ev.token ).to eql 'nodo'
        a = ev.item_stream_proc.call.to_a
        expect( a.length ).to eql 1
        expect( a.first.value ).to eql :__frodo_baggins__

        expect( in_st.current_index ).to eql 0
      end

      it "a partial match gets you nothing (end of input)" do

        in_st = input_stream_via_array %w( frodo )

        expect( _go( in_st, & handle_event_selectively_ ) ).to eql false

        expect( black_and_white _want_common_event ).to eql(
          _at_end_expecting 'baggins' )

        expect( in_st.current_index ).to be_zero
      end

      it "a strange token at the beginning" do

        in_st = input_stream_via_array %w( nodo )

        expect( _go( in_st, & handle_event_selectively_ ) ).to eql false

        expect( black_and_white( _want_common_event ) ).to eql(
          "#{ _uninterpretable 'nodo' }#{ _expecting 'frodo', 'bilbo' }" )

        expect( in_st.current_index ).to be_zero
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

        expect( _go( in_st ).value ).to eql :__elizabeth_keen_tom_keen__

        expect( in_st.current_index ).to eql 5
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

        expect( _go( in_st, & handle_event_selectively_ ).value ).to eql :__xx_yy__

        expect( in_st.current_index ).to eql 2
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

      expect( _st.gets.value ).to eql :__a_b__
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

    def _want_common_event

      _em = want_not_OK_event :expecting
      _em.cached_event_value
    end
  end
end
