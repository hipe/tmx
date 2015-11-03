require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter - set" do

    extend TS_
    use :sandboxed_kernels

    it "set with a bad name - expresses good name(s)" do

      @subject_kernel_ = read_only_kernel_with_no_data_

      future_expect_only :error, :extra_properties do | ev |

        _s = future_black_and_white ev

        _s.should match %r(\Aunrecognized adapter 'wazoozle'//#{
          }did you mean .*'imagemagick'.*\?\z)
      end

      call_ :adapter, :set, :adapter, "wazoozle"

      expect_failed_
    end

    context "successful initial set" do

      it "(matches fuzzily!) emits natural sounding event" do

        on_past_emissions _good_set_state.emissions

        past_expect_eventually :info, :component_added do | ev |

          _s = past_black_and_white ev
          _s.should eql "added adapter 'imagemagick' to appearance"
        end
      end

      it "emits wrote event" do

        on_past_emissions _good_set_state.emissions

        past_expect_eventually :info, :wrote do | ev |

          ev.preterite_verb.should eql 'wrote'
          ev.path.should match %r(\[mt\]/[-a-z0-9]+\.json\z)
          ( 29..32 ).should be_include ev.bytes  # :P
        end
      end

      it "results in true" do

        _good_set_state.result.should eql true
      end

      it "creates JSON file that looks right" do

        _ev = _good_set_state.emissions.last.event_proc[]   # egads
        _act = ::File.read _ev.path
        _act.should eql appearance_JSON_one_
      end

      dangerous_memoize_ :_good_set_state do

        @subject_kernel_ = new_mutable_kernel_with_no_data_

        state = begin_state_

        call_ :adapter, :set, :adapter, "imagemag", & state.proc

        state.finish
      end
    end

    attr_reader :subject_kernel_  # LOOK you must set this at every test
  end
end
