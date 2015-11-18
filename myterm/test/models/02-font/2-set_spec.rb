require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - set" do

    extend TS_
    use :sandboxed_kernels

    context "bad name (FRAGILE)" do

      it "explains skipped font files (FRAGILE), does levenshtein!" do

        @subject_kernel_ = new_mutable_kernel_with_appearance_ appearance_JSON_one_

        future_expect :info, :expression, :skipped

        future_expect :error, :extra_properties do | ev |
          _s = future_black_and_white ev
          _s.should match(
           %r(\Acouldn't set background font because #{
             }unrecognized font path 'NOTAFONT'//#{
              }did you mean '[^']+', '[^']+' or '[^']+'\?\z) )
        end

        call_ :background_font, :set, :path, 'NOTAFONT'

        expect_failed_
      end
    end

    context "good name (FRAGILE)" do

      it "results in true (i.e appears to succeed)" do

        _state.result.should eql true
      end

      it "natural expression comes of 'component_added'" do

        on_past_emissions _state.emissions

        past_expect_eventually :info, :component_added do | ev |

          _s = future_black_and_white ev
          _s.should eql 'set background font to "Monaco.dfont"'
        end
      end

      it "writes correct-looking JSON" do

        state = _state
        on_past_emissions state.emissions

        past_expect_eventually :info, :wrote do | ev |

          ( 141 .. 141 ).should be_include ev.bytes  # etc

          ev.preterite_verb.should eql "wrote"
        end

        _s = state.kernel._string_IO_for_testing_.string
        _exp_rx = /\A\{\n
          [ ][ ]"adapter":[ ]"imagemagick",\n
          [ ][ ]"adapters":[ ]{\n
          [ ]{4}"imagemagick":[ ]{\n
          [ ]{6}"background_font":[ ]"[^"]+"
        /x

        _s.should match _exp_rx
      end

      dangerous_memoize_ :_state do

        _ke = new_mutable_kernel_with_appearance_ appearance_JSON_one_.dup
        @subject_kernel_ = _ke

        state = begin_state_

        call_ :background_font, :set, :path, 'monaco', & state.proc

        state.finish
      end
    end

    it "what if you try to set with no adapter selected? - DYNAMIC INTERFACE" do

      future_expect_only :error, :no_such_action do | ev |

        ev.action_name.should eql :background_font
      end

      @subject_kernel_ = new_mutable_kernel_with_no_data_

      call_ :background_font, :set, :path, 'monaco'

      expect_failed_
    end

    _EXISTENT_FONT = 'monaco'
      # (below assumes this name never needs escaping, neither RX or quotes)

    it "after having set it, you can get it (FRAGILE)" do

      _s = _persistence_payload_for _EXISTENT_FONT

      @subject_kernel_ = new_mutable_kernel_with_appearance_ _s

      call_ :background_font, :get

      _s = @result.description_under future_expression_agent_instance
      _s.should eql '"Monaco.dfont"'
    end

    context "after having set it, setting it to something else (ALL FRAGILE)" do

      it "results in true (appears to succeed)" do

        _state.result.should eql true
      end

      _OTHER = 'Courier.dfont'

      it "serialization payload looks good" do

        _string_IO = _state.kernel._string_IO_for_testing_

        _string_IO.string.should be_include _OTHER
      end

      it "expresses a 'component added' emission WITH CONTEXT CHAIN" do

        on_past_emissions _state.emissions

        past_expect_eventually :info, :component_changed do | ev |

          _s = future_black_and_white ev

          _s.should match %r(\Achanged background font from #{
            }"#{ _EXISTENT_FONT }[^"]*" to #{
              }"#{ ::Regexp.escape _OTHER }"\z)i
        end
      end

      dangerous_memoize_ :_state do

        s = _persistence_payload_for _EXISTENT_FONT
        _ke = new_mutable_kernel_with_appearance_ s

        @subject_kernel_ = _ke

        state = begin_state_

        call_ :background_font, :set, :path, 'courier', & state.proc

        state.finish
      end
    end

    def _persistence_payload_for s  # BE CAREFUL - we don't escape the name!

      <<-HERE.unindent
        {
          "adapter": "imagemagick",
          "adapters": {
            "imagemagick": {
              "background_font" : "#{ s }"
            }
          }
        }
      HERE
    end

    attr_reader :subject_kernel_
  end
end