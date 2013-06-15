module Skylab::Test

  class Plugins::Subtree::And_

    def initialize a, yes=nil, no=nil, conflict=nil
      @yes, @no, @conflict = yes, no, conflict
      @a = if a.length.zero?
        [ PASS_ ]
      else
        a.dup
      end
    end

    class Pass_
      def pass *_
        :yes
      end
    end

    PASS_ = Pass_.new

    def if_pass sp, pn, yes=nil, no=nil, conflict=nil
      confl_a = nil
      res = agt = nil
      @a.each do |ag|
        r = ag.pass sp, pn
        r or fail "fix the below logic if you have a `nil` pass response."
        if res
          if res != r
            ( confl_a ||= [ ] ) << [ ag, r ]
            break  # for now
          end
        else
          res = r
          agt = ag
        end
      end
      if confl_a
        ( conflict || @conflict ).call(
          [ sp, pn, confl_a.unshift( [ agt, res ] ) ]
        )
      elsif :yes === res
        ( yes || @yes ).call
      elsif :no == res
        ( no || @no ).call
      else
        raise "agent `pass` result was invalid ( #{ r.inspect } from #{
          }#{ ag.to_s })"
      end
    end
  end
end
