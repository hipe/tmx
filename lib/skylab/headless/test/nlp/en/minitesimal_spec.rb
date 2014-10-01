require_relative '../test-support'

describe "[hl] NLP EN minitesimal FUN" do

  extend ::Skylab::Headless::TestSupport::NLP

  fun = self::Headless_::NLP::EN::Minitesimal::FUN

  context "oxford_comma" do

    o = -> s, *a do
      t = [(a.pop if ::Hash === a.last)].compact
      it "#{s}", *t do
        so = fun.oxford_comma[ a ]
        so.should eql(s)
      end
    end

    o[ 'four, three, two and one', * %w(four three two one) ]

    o[ 'three, two and one', * %w(three two one) ]

    o[ 'two and one', * %w(two one) ]

    o[ 'one', 'one' ]

    o[ nil ]

  end


  context "s" do

    define_method :s, & fun.s

    define_method :_and do |a|
      x = fun.oxford_comma[ a ]
      x and " #{ x }"
    end

    # ( has a complimentary test in `nlp_spec.rb` )

    o = -> a, n, so, *t do
      it "#{ so }", *t do
        x = "#{ s a, :no }known person#{ s a } #{ s a, :exis}#{ _and a }#{
          } in #{ s n, :this }#{ " #{ n }" if 1 != n } location#{ s n }."
        x.should eql( so )
      end
    end

    o[ %W(A B C), 0, 'known persons are A, B and C in these 0 locations.' ]

    o[ %W(A B), 1,  'known persons are A and B in this location.' ]

    o[ %W(A), 2, 'the only known person is A in these 2 locations.' ]

    o[ [], 3, 'no known persons exist in these 3 locations.' ]

  end
end
