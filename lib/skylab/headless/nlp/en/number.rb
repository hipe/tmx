module Skylab::Headless::NLP::EN::Number

  -> o do                         # A scope to hold what is effectively
                                  # private constants.
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

    big = [nil, nil, nil, 'hundred',
           'thousand', nil, nil, 'million', nil, nil, 'billion'] # and so on

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
      end.compact.join ' '
    end

    o[:number] = number

    o[:num2ord] = -> x do
      return x unless x % 1 == 0 && x > 0 # positive integers only
      mod = x % (m = 100)
      if mod >= arr.length and !(13..19).include? mod
        mod = x % (m = 10)
      end
      if mod < arr.length && arr[mod].length >= 2
        [ number[ x / m * m ],
          arr[mod][2] ? arr[mod][1] : "#{arr[mod].last}th"
        ].compact.join ' '
      else
        number[ x ].sub(/ty$/, 'tie').concat 'th'
      end
    end

  end.call( h = { } )

  FUN = ::Struct.new(* h.keys ).new ; h.each { |k, v| FUN[k] = v }
                                  # Take a hash full of functions and
                                  # make it a struct full of functions (a
                                  # much better public interface for at least
                                  # two resasons).


  module Methods                  # a version of some of our functions as
                                  # instance methods.  Use them as ModuleMethods
                                  # or InstanceMethods, up to you.

    define_method :number, & FUN.number

    define_method :num2ord, & FUN.num2ord

  end
end
