require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter - set" do

    extend TS_
    use :sandboxed_kernels

    it "set with a bad name - expresses good name(s)" do

      @subject_kernel_ = read_only_kernel_with_no_data_

      future_expect_only :error, :extra_properties do | ev |

        _s = future_black_and_white ev

        _s.should match %r(\Acouldn't set adapter because #{
          }unrecognized adapter 'wazoozle'//#{
            }did you mean .*'imagemagick'.*\?\z)
      end

      call_ :adapter, :set, :adapter, "wazoozle"

      expect_failed_
    end

    context "successful initial set" do

      it "appears to work (results in true)" do

        _state.result.should eql true
      end

      it "(matches fuzzily!) emits natural sounding event" do

        past_expect_eventually :info, :component_added do | ev |

          _s = past_black_and_white ev
          _s.should eql "set adapter to 'imagemagick'"
        end
      end

      it "emits 'wrote' event" do

        _expect_same_wrote_event
      end

      it "creates JSON file that looks right" do

        _expect_same_JSON_file
      end

      def past_emissions
        _state.emissions
      end

      dangerous_memoize_ :_state do

        @subject_kernel_ = new_mutable_kernel_with_no_data_

        state = begin_state_

        call_ :adapter, :set, :adapter, "imagemag", & state.proc

        state.finish
      end

      def _written_JSON_string

        _em = _state.emissions.only_on :info, :wrote

        _ev = _em.event_proc[]

        ::File.read _ev.path
      end
    end

    context "successful subsequent set" do

      it "works (results in true)" do
        _state.result.should eql true
      end

      it "natural" do

        past_expect_eventually :info, :component_changed do | ev |
          _s = future_black_and_white ev
          _s.should eql(
            "changed adapter from 'imagemagick' to 'imagemagick'" )
        end
      end

      it "emits 'wrote' event" do
        _expect_same_wrote_event
      end

      def past_emissions
        _state.emissions
      end

      it "updates JSON file that looks right" do
        _expect_same_JSON_file
      end

      def _written_JSON_string

        _state.kernel._string_IO_for_testing_.string
      end

      dangerous_memoize_ :_state do

        @subject_kernel_ = new_mutable_kernel_with_appearance_ appearance_JSON_one_.dup

        state = begin_state_

        call_ :adapter, :set, :adapter, 'imagemag', & state.proc

        state.finish
      end
    end

    def _expect_same_wrote_event

      past_expect_eventually :info, :wrote do | ev |

        ev.preterite_verb.should eql 'wrote'
        ev.path.should match %r(\[mt\]/[-a-zA-Z0-9]+\.json\z)
        ( 31..109 ).should be_include ev.bytes  # :P
      end
    end

    def _expect_same_JSON_file

      _act = _written_JSON_string
      _act.should eql appearance_JSON_one_
    end

    attr_reader :subject_kernel_  # LOOK you must set this at every test
  end
end
