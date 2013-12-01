module Skylab::Headless

  module NLP

    en_inflector = ::Class.new( ::Module ).class_exec do
      Headless::SubClient::EN_FUN.each_pair do |m, p|
        define_method m, &p
      end
      self
    end

    EN = en_inflector.new

    module EN::Minitesimal
    end

    EN::Minitesimal.const_set :Inflector_, en_inflector

    class << EN
      alias_method :calculate, :instance_exec
    end
  end

  module NLP::EN::Minitesimal

    o = { }

    # `an` - crude hack-guess at 'a' vs. 'an'

    o[:an] = -> lemma_x, cnt=nil do
      "#{ An_[ lemma_x, cnt ] }#{ lemma_x }" if lemma_x
    end

    initial_vowel_rx = /\A[aeiou]/i

    all_caps_rx = /\A[A-Z]+\z/

    An_ = o[:an_] = -> lemma_x, cnt=nil do
      lemma_s = lemma_x.to_s
      if lemma_s.length.nonzero?
        r = S_[ cnt || 1, initial_vowel_rx =~ lemma_s ? :an : :a ]
        if r && all_caps_rx =~ lemma_s
          r = r.upcase
        end
        r
      end
    end

    Oxford_comma = -> sep, ult, a do
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

    coc = o[:curriable_oxford_comma] = -> ult, sep, a do
      Oxford_comma[ sep, ult, a ]  # #todo:after-the-fire
    end

    o[:oxford_comma] = -> a, ult = " and ", sep = ", " do
      coc[ ult, sep, a ]
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
      was: ['were', 'was', 'were'],
     them: ['them', 'it', 'them'],
        y: ['ies', 'y', 'ies']
    }

    ( norm = { 0 => 0, 1 => 1 } ).default = 2

    S_ = o[:s] = -> a, v=:s do
      count = ::Numeric === a ? a : a.length  # if float, watch what happens
      zero_one_two = norm[ count ]
      inflected.fetch( v )[ zero_one_two ]
    end

    o[:both] = -> x do
      'both ' if 2 == ( ::Numeric === x ? x : x.length )
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

    FUN_ = ::Struct.new( * o.keys )
    FUN = FUN_.new( * o.values ).freeze

  end
end
