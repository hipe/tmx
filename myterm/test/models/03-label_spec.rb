require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - label", wip: true do

    extend TS_
    use :sandboxed_kernels

    it "with a good font but invalid label - natural" do

      future_expect_only :error, :nonblank do | ev |

        _s = future_black_and_white ev

        _s.should eql "couldn't set label because label cannot be blank"
      end

      @subject_kernel_ = _kernel_without_system

      call_ :label, :set, :x, ''

      @result.should eql false
    end

    context "with good font and good label" do

      it "succeeds" do

        _state.result.should eql true
      end

      it "natural message" do

        past_expect_eventually :info, :component_added do | ev |
          _s = future_black_and_white ev
          _s.should eql "set label to \"welff\""
        end
      end

      it "JSON looks good" do

        _string_IO = _state.kernel._string_IO_for_testing_
        _string_IO.string.should be_include '"welff"'
      end

      it "shows the applescript" do

        past_expect_eventually :info, :expression, :command do | s_a |
          s_a.first.should match %r(\(attempting: convert )
        end
      end

      def past_emissions
        _state.emissions
      end

      dangerous_memoize_ :_state do
        @subject_kernel_ = _kernel_without_system
        state = begin_state_
        call_ :label, :set, :x, 'welff', & state.proc
        state.finish
      end
    end

    build_fake_system_conduit = nil

    dangerous_memoize_ :_kernel_without_system do

      _fake_payload = persistence_payload_for_font_ 'i_am_a_FONT'

      ke = start_a_kernel_

      edit_kernel_by_ ke do | o |

        o.accept_persistence_payload_string _fake_payload

        o.mess_with_installation do | inst |

          # when the controller asks for `fonts_dir`, give it this string:

          inst.redefine :fonts_dir do
            '/talisker'
          end

          # when the thing globs on that dir, give it these paths

          inst.replace_with_dynamic_stub :filesystem do | fs |

            fs.if_then :glob, '/talisker/*' do
              [ '/talikser/wazoozle.dfont', '/talisker/I_AM_a_font.dfont' ]
            end
          end

          x = nil
          inst.redefine :system_conduit do
            x ||= build_fake_system_conduit[]
          end
        end
      end

      ke
    end

    build_fake_system_conduit = -> do

      empty = Callback_::Stream.the_empty_stream
      _wait = Home_.lib_.system.test_support::MOCKS.successful_wait

      success = [
        nil,  # stdin
        empty,  # stdout
        empty,  # stderr
        _wait,
      ]
      success_p = -> do
        success
      end

      TS_::Mess_With::Make_dynamic_stub_proxy.call :NO do | o |

        o.if_then_maybe :popen3 do | * args, & p |  # ETC

          if 'convert' == args.first
            success_p
          elsif 'osascript' == args.first
            success_p
          else
            self._ETC
          end
        end
      end
    end

    attr_reader :subject_kernel_
  end
end
