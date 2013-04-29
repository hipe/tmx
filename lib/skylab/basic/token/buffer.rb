module Skylab::Basic

  class Token::Buffer

    def initialize sep_rx, word_rx
      scn = Services::StringScanner.new ''
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
                    Services::Headless::CLI::FUN.ellipsify[ scn.rest, 8 ] }\""
                end
                stay = false
              end
            end while stay
            res
          end
        end
      end
    end

    def gets_proc= x
      @gets_proc[ x ]
    end

    def gets
      @gets.call
    end
  end
end
