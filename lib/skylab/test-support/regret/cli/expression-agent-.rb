module Skylab::TestSupport

  module Regret

    module CLI

      class Expression_Agent_

        # a reconception of the pen. imagine accessibility and text to speech.
        # we have hopes for this to flourish upwards and outwards.
        # think of it as a proxy for that subset of your modality client that
        # does rendering. you then pass that proxy to the snitch, which is
        # passed throughout the application and is the central conduit though
        # which all expression is received and then articulated.

        def initialize mechanics
          @hi = mechanics.method( :hi )
        end

        # a normal template string -
        #   "invalid #{ lbl x } value #{ ick x } - expecting #{ or_ a }"

        def lbl x
          x
        end

        def ick string
          "\"#{ string }\""
        end

        def or_ a
          Subsys::Services::Headless::NLP::EN::Minitesimal::FUN.
            oxford_comma[ a.map( & method( :val ) ), ' or ' ]
        end

        def val x
          @hi[ x ]  # or not
        end
      end
    end
  end
end
