module Skylab::Brazen::TestSupport

  module Property::Stack::Models::Common_Frame

    subject = -> * a do

      if a.length.zero?
        Home_::Property::Stack.common_frame

      else
        Home_::Property::Stack.common_frame.call_via_arglist a
      end
    end

    define_singleton_method :prepare_sandbox do | mod |

      # (we have to set these explicitly, we can't just include one
      # single constants module into the module, because #[#ts-044].)

      mod.const_set :Home_, Home_
      mod.const_set :Subject_, subject

      mod.extend TestSupport_::Quickie

      NIL_
    end
  end
end
