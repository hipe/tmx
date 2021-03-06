module Skylab::MyTerm::TestSupport

  module Stubs::SYSTEM_CONDUIT_01_HI____
    def self.is_fake_
      true
    end
  end

  module Stubs::System_Conduit_01_Hi

    _build_instance = -> do

      empty = Common_::THE_EMPTY_STREAM

      _wait = Home_.lib_.system.test_support::STUBS.successful_wait

      success = [
        nil,  # stdin
        empty,  # stdout
        empty,  # stderr
        _wait,
      ]

      success_p = -> do
        success
      end

      _real = Stubs::SYSTEM_CONDUIT_01_HI____

      _stub = TS_::Mess_With::Make_dynamic_stub_proxy.call _real do |o|

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

      _stub
    end

    define_singleton_method :instance, Lazy_.call( & _build_instance )
  end
end
