module Skylab
  module Porcelain
    module En
      module Number
      end
    end
  end
end

module Skylab::Porcelain::En::Number
  def num2ord x
    return x unless x % 1 == 0 && x > 0 # positive integers only
    mod = x % (m = 100)
    if mod >= ARR.length and !(13..19).include?(mod)
      mod = x % (m = 10)
    end
    if mod < ARR.length && ARR[mod].length >= 2
      [ number( x / m * m), ARR[mod][2] ? ARR[mod][1] : "#{ARR[mod].last}th" ].compact.join(' ')
    else
      number(x).sub(/ty$/, 'tie').concat('th')
    end
  end
end

module Skylab::Porcelain::En::Number
  ARR = [
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
  BIG = [nil, nil, nil, 'hundred', 'thousand', nil, nil, 'million', nil, nil, 'billion'] # etc
  def number x
    x % 1 == 0 && x >= 0 or return x # positive integers only
    case x
    when 0          ; return nil
    when 1..12      ; [ARR[x].first]
    when 13..19     ; ["#{ARR[x % 10].last}teen"]
    when 20..99     ; ["#{ARR[x / 10].last}ty", number(x % 10)]
    when 1099..1999 ; ["#{number(x / 100)} hundred", number(x % 100)] # (to be cute, can comment out)
    else            ; d = 0 ; n = x.to_int ; (n /= 10) while ( n > 0 && d += 1 )
                    ; b = [BIG.length - 1, d].min ; b -= 1 until BIG[b] ; div = 10 ** (b-1)
                    ; ["#{number(x / div)} #{BIG[b]}", number(x % div)]
    end.compact.join(' ')
  end
end

if __FILE__ == $PROGRAM_NAME
  include Skylab::Porcelain::En::Number
  method = nil
  print = ->(x) { $stderr.puts("#{'%9d' % [x]}:-->#{method.call(x)}<--") }
  [
    ->(x) { number(x) },
    ->(x) { num2ord(x) }
  ].each do |m|
    method = m
    (0..9).each(&print)
    (10..13).each(&print)
    (14..19).each(&print)
    [20, 21, 22, 23, 24, 25, 26, 27, 28, 29].each(&print)
    [30, 31, 40, 50, 60, 70, 80, 90, 99].each(&print)
    [100, 101, 200, 203, 300, 399, 827, 998, 999].each(&print)
    [1000, 1001, 1423, 1900, 1999, 2000, 2001].each(&print)
    [42388].each(&print)
    [7000_000_000_000_000_000_000_000].each(&print)
  end
end
