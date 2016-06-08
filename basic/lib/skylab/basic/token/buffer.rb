module Skylab::Basic

  class Token::Buffer

    def initialize sep_rx, word_rx
      scn = Home_.lib_.empty_string_scanner
      up_gets = nil ; is_hot = true
      @gets_proc = -> x { up_gets = x }
      load_scn = -> do
        str = up_gets.call
        if str
          scn.string = str
        else
          is_hot = false
        end
      end
      @gets = -> do
        if is_hot
          scn.eos? and load_scn[]
          if is_hot  # we don't check for eos again, has effect of barking about ''
            res = nil ; stay = true
            begin
              scn.skip sep_rx
              if scn.eos?
                load_scn[] or stay = false
              else
                res = scn.scan word_rx
                if ! res
                  fail "sanity - expecting word (#{ word_rx }) near \"#{
                    Ellipsatize__[ scn.rest ] }\""
                end
                stay = false
              end
            end while stay
            res
          end
        end
      end
    end

    A_RATHER_SHORT_LENGTH_FOR_A_STRING__ = 8

    Ellipsatize__ = Home_::String.ellipsify.
      curry[ A_RATHER_SHORT_LENGTH_FOR_A_STRING__ ]

    Common_::Session::Ivars_with_Procs_as_Methods.call self,
      :gets, :@gets_proc, :gets_proc=

  end
end
