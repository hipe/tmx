module Skylab::Headless

  module NLP

    module EN::Number

  -> o do

    arr = [
      %w(zero),
      %w(one first x),
      %w(two second twen),
      %w(three third thir),
      %w(four for),
      %w(five fif),
      %w(six),
      %w(seven),
      %w(eight eigh),
      %w(nine nin),
      %w(ten),
      %w(eleven),
      %w(twelve twelf)
    ]

    _TERM_SEPARATOR_STRING = ::Skylab::Headless::TERM_SEPARATOR_STRING_

    big = [ nil, nil, nil, 'hundred', 'thousand',
            nil, nil, 'million',
            nil, nil, 'billion' ]  # and so on

    number = -> x do
      x % 1 == 0 && x >= 0 or return x # positive integers only
      case x
      when 0          ; return nil
      when 1..12      ; [arr[x].first]
      when 13..19     ; ["#{arr[x % 10].last}teen"]
      when 20..99     ; ["#{arr[x / 10].last}ty", number[ x % 10 ]]
      when 1099..1999 ; ["#{number[ x / 100 ]} hundred", number[ x % 100 ]]
                                # (to be cute, can comment out)
      else
         d = 0 ; n = x.to_int ; (n /= 10) while ( n > 0 && d += 1 )
         b = [big.length - 1, d].min ; b -= 1 until big[b] ; div = 10 ** (b-1)
         ["#{number[ x / div ]} #{big[b]}", number[ x % div ]]
      end.compact * _TERM_SEPARATOR_STRING
    end

    o[ :number ] = number

    o[ :num2ord ] = Num2ord = -> x do
      return x unless x % 1 == 0 && x > 0 # positive integers only
      mod = x % (m = 100)
      if mod >= arr.length and !(13..19).include? mod
        mod = x % (m = 10)
      end
      if mod < arr.length && arr[mod].length >= 2
        [ number[ x / m * m ],
          arr[mod][2] ? arr[mod][1] : "#{arr[mod].last}th"
        ].compact * _TERM_SEPARATOR_STRING
      else
        number[ x ].sub(/ty$/, 'tie').concat 'th'
      end
    end

  end.call -> do
    o = -> i, p do
      define_singleton_method i do | * a |
        if a.length.zero?
          p
        else
          p[ * a ]
        end
      end ; nil
    end
    class << o
      alias_method :[]=, :call
    end
    o
  end.call

      Number_ = self

      module Methods
        define_method :number, Number_.number
        define_method :num2ord, Number_.num2ord
      end

    end  # EN::Number
  end  # NLP
end
