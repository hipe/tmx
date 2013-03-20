module Skylab::Headless

  module NLP

    module EN
      # forward declarations should be flattened as needed
    end
  end

  module NLP::EN::Minitesimal

    o = { }

    initial_vowel_rx = /\A[a-e]/i

    all_caps_rx = /\A[A-Z]+\z/

    # `an` - crude hack-guess at 'a' vs. 'an'

    o[:an] = -> lemma_x, cnt=nil do
      lemma = lemma_x.to_s
      if lemma.length.nonzero?
        res = o[:s][
          cnt || 1,
          initial_vowel_rx =~ lemma ? :an : :a
        ]
        if res && all_caps_rx =~ lemma
          res = res.upcase
        end
        res
      end
    end

    o[:oxford_comma] = -> a, ult = " and ", sep = ", " do
      if a.length.nonzero?
        res = ( 1 .. ( a.length - 2 ) ).reduce [ a[0] ] do |ar, idx|
          ar << sep << a[idx]
        end
        if 1 < a.length
          res << ult << a[-1]
        end
        res * ''
      end
    end

    inflected = {
        a: ['no ', 'a '],              # no birds  / a bird   / birds
       an: ['no ', 'an '],             # no errors / an error / errors
     exis: ['exist', 'is', 'are'],
       is: ['are', 'is', 'are'],
       no: ['no ', 'the only '],
        s: ['s', nil, 's'],
       _s: [ nil, 's' ],               # it requires, they require
     this: ['these', 'this', 'these'],
      was: ['were', 'was', 'were']
    }

    ( norm = { 0 => 0, 1 => 1 } ).default = 2

    o[:s] = -> a, v=:s do
      count = ::Numeric === a ? a : a.length  # if float, watch what happens
      zero_one_two = norm[ count ]
      inflected.fetch( v )[ zero_one_two ]
    end

    -> do  # `inflect` - goofy experiment for low-commitment inflection

      pool_a = [ ]

      o[:inflect] = -> func do
        x = pool_a.length.zero? ? Inflector_.new : pool_a.pop
        res = x.instance_exec(& func )
        pool_a << x
        res
      end
    end.call

    class Inflector_
      Headless::SubClient::EN_FUN.each do |m, f|
        define_method m, &f
      end
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end
end
