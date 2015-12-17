require_relative 'test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] 2 - tree spec" do

    TS_[ self ]

    context "call top node with something strange:" do

      shared_subject :state_ do
        call_ :something
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "message tail enumerates the available items (with glyphs)" do

        only_emission.should ( be_emission :error, :uninterpretable_token do | ev |

          _ = black_and_white ev

          _.should match %r(, expecting \{ subject \| verb_phrase \}\z)
        end )
      end
    end

    it "persist this full ACS when we hack values into it - OK" do

      @oes_p_ = Future_Expect_[ :info, :wrote ]

      o = _build_full_graph

      _act = o.persist_into_ ""

      _exp = <<-HERE.unindent
        {
          "subject": "i",
          "verb_phrase": {
            "verb": "love",
            "object": "chocolate"
          }
        }
      HERE

      _act.should eql _exp

      @oes_p_.done_
    end

    context "when payload looks wrong:" do

      shared_subject :state_ do

        _ = build_top_

        _wrong = <<-HERE.unindent
          {
            "subject": "i",
            "verb_phrase": {
              "verb": "love",
              "object": "/chocolate"
            }
          }
        HERE

        io = TestSupport_::Library_::StringIO.new( _wrong )

        @result = _.unmarshal_from_  io

        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "emits (no contextualization yet)" do

        only_emission.should ( be_emission(
          :error, :expression, :invalid_value
        ) do | y |

          y.should eql [ "paths can't be absolute - '/chocolate'" ]

        end )
      end
    end

    context "deep time" do

      shared_subject :state_ do

        call_( :subject, 'you',
          :verb_phrase,
            :object, 'cocoa',
            :verb, 'like',
        )

        flush_state_
      end

      it "wins" do
        expect_result_for_success_
      end

      it "evo" do

        be_this_emission = be_emission :info, :set_leaf_component
        st = Callback_::Stream.via_nonsparse_array state_.emission_array

        3.times do
          _ = st.gets
          _.should be_this_emission
        end
        st.gets and fail
      end
    end

    def _build_full_graph

      o = build_top_

      o._set_subject 'i'

      o_ = _build_verb_phrase

      o_._set_verb 'love'

      o_._set_object 'chocolate'

      o._set_verb_phrase o_

      o
    end

    def top_ACS_class_
      _require_model
      Two_Sentence
    end

    def _build_verb_phrase
      _require_model
      Two_Verb_Phrase.new
    end

    dangerous_memoize :_require_model do

      module Two_Etc__

        def receive_component__error__
          self._RESPOND_TO_ONLY
        end

        def receive_component__error__expression__ qkn, sym, & ev_p
          _expy qkn, sym, & ev_p
        end
      end

      class Two_Sentence

        include Unmarshal_and_Call_and_Marshal_
        include Two_Etc__

        def __subject__component_association
          File_Name_Model_
        end

        def __verb_phrase__component_association
          Two_Verb_Phrase
        end

        def _set_subject x
          @subject = x ; nil
        end

        def _set_verb_phrase o
          @verb_phrase = o ; nil
        end

        def _expy qkn, sym, & ev_p

          @oes_p_.call :error, :expression, sym do | y |

            instance_exec y, & ev_p
          end
          NIL_
        end
      end

      class Two_Verb_Phrase

        include Unmarshal_and_Call_and_Marshal_
        include Two_Etc__

        def self.interpret_compound_component p, & x
          p[ new( & x ) ]
        end

        def initialize & x
          @_xp = x
        end

        def __verb__component_association
          File_Name_Model_
        end

        def __object__component_association
          File_Name_Model_
        end

        def _set_verb x
          @verb = x ; nil
        end

        def _set_object x
          @object = x ; nil
        end

        def _expy qkn, sym, & ev_p

          _oes_p = @_xp[ self ]

          _oes_p.call :error, :expression, sym do | y |

            instance_exec y, & ev_p
          end
          NIL_
        end
      end

      NIL_
    end
  end
end
