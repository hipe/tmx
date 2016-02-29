require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] sexp - expression sessions - list thru c.agg. - features" do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :sexp_expression_sessions_list_through_columnar_aggregation

    context "expander (when no input)" do

      dangerous_memoize :subject do

        su = subject_call_(

          :on_zero_items, -> y do
            y << 'nerp'
          end,

          :template, "{{ wazzah }}",
        )
        SESLtA_Exp = su
        su
      end

      it "loads" do
        subject
      end

      it "zero items" do
        expect_line 'nerp'
        expect_no_more_lines
      end

      it "one item" do
        push 'wizzie'
        expect_line 'wizzie'
        expect_no_more_lines
      end
    end

    context "on fist mention" do

      dangerous_memoize :subject do

        su = subject_call_(

          :template, '{{ who-hah }} {{ nec }}',

          :'who-hah', :on_first_mention, -> y, x do
            y << ( x.gsub( /([aeiou])/ ) {  '%c' % ( $1.ord + 6 ) } ).upcase
          end,
        )
        SESLtA_OFM = su
        su
      end

      it "loads" do
        subject
      end

      it "works." do
        push 'ding', 'dung'
        push 'ding', 'dong'
        expect_line 'DONG dung'
        expect_line 'ding dong'
        expect_no_more_lines
      end
    end

    context "derivative fields" do

      dangerous_memoize :subject do

        su = subject_call_(

          :template, '{{ np }}{{ vp }}{{ adv }}',

          :adv, :on_subsequent_mentions_of, :field, :vp, -> y, _ do
            y << ' also'
          end,
        )
        SESLtA_Of = su
        su
      end

      it "loads" do
        subject
      end

      it "works" do
        push 'i', ' want candy', 'no see 1'
        push 'you', ' want candy', 'no see 2'
        expect_line 'i want candy'
        expect_line 'you want candy also'
        expect_no_more_lines
      end
    end

    context "impetus example" do

      dangerous_memoize :subject do

        su = subject_call_(

          :on_zero_items, -> y do
            y << "nothing happened."
          end,

          :template, "{{ store }}{{ adv }} has the required {{ item }}#{
            } needed by {{ needer }}{{ adv2 }}.",

            :store,
              :on_first_mention, -> y, x do
                y << x.to_s.upcase
              end,
              :on_subsequent_mentions, -> y, x do
                y << 'it'
              end,

            :adv,
              :on_subsequent_mentions_of, :field, :store, -> y, _ do
                y << " also"
              end,

            :item,
              :on_first_mention, -> y, x do
                y << "item \"#{ x }\""
              end,
              :aggregate, -> y, a do
                y << "items (#{ a * ', ' })"
              end,

            :needer,
              :on_first_mention, -> y, x do
                y << x.to_s.upcase
              end,
              :on_subsequent_mentions, -> y, x do
                y << 'that needer too'
              end,

            :adv2,
              :on_subsequent_mentions_of, :field, :store, -> y, _ do
                y << ' too'
              end,
        )
        SESLtA_Art = su
        su
      end

      it "loads" do
      end

      it "none - \"nothing happened\"" do
        flush 'nothing happened.'
      end

      it "one - says first things first" do
        push 'iOS programming', 'excitement', 'me'
        flush "IOS PROGRAMMING has the required item \"excitement\" #{
          }needed by ME."
      end

      it "two inputs, one frame, aggregate two items please." do
        push 'scala', 'thrill', 'me'
        push 'scala', 'ecstasy', 'me'
        flush 'SCALA has the required items (thrill, ecstasy) needed by ME.'
      end

      it "two inputs, left same" do
        push 'haskell', 'fun', 'rob'
        push 'haskell', 'challenge', 'me'
        flush "HASKELL has the required item \"fun\" needed by ROB. it also #{
          }has the required item \"challenge\" needed by ME too."
      end

      it "three inputs, left has two, right always same" do
        push 'clojure', 'wanky', 'me'
        push 'clojure', 'danky', 'me'
        push 'scala',   'panky', 'me'
        flush "CLOJURE has the required items (wanky, danky) needed by ME. #{
          }SCALA has the required item \"panky\" needed by that needer too."
      end

      def push one, two, three  # LOOK
        super one, :_no_see_for_adv_, two, three, :_no_see_for_adv2_
      end

      def flush expected_string
        s_a = nil
        s = output_scn.gets
        if s
          s_a = [ s ]
          while s = @output_scn.gets
            s_a.push Home_::SPACE_
            s_a.push s
          end
        end
        if s_a
          output_s = s_a.join Home_::EMPTY_S_
        end
        output_s.should eql expected_string
      end
    end
  end
end
