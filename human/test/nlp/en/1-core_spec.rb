require_relative '../../test-support'

describe "[hu] NLP EN minitesimal" do  # :#here-2

  context "s" do

    # ( has a counterpart test in sibling `methods_spec.rb` )

    o = -> a, n, so, *t do
      it "#{ so }", *t do
        x = "#{ s a, :no }known person#{ s a } #{ s a, :exist }#{ _and a }#{
          } in #{ s n, :this }#{ " #{ n }" if 1 != n } location#{ s n }."
        x.should eql( so )
      end
    end

    o[ %W(A B C), 0, 'known persons are A, B and C in these 0 locations.' ]

    o[ %W(A B), 1,  'known persons are A and B in this location.' ]

    o[ %W(A), 2, 'the only known person is A in these 2 locations.' ]

    o[ [], 3, 'no known persons exist in these 3 locations.' ]

    def s * a
      _lib.s( * a )
    end

    def _and a
      x = _lib::Oxford_and[ a ]
      x && " #{ x }"
    end
  end

  def _lib
    ::Skylab::Human::NLP::EN
  end
end
