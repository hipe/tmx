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

    o[:an] = -> x, cnt=nil do          # crude guess at 'a' vs. 'an'
      x = x.to_s
      res = initial_vowel_rx =~ x ? 'an' : 'a'
      if cnt                           # if the count is also variable then
        res = o[:s][ cnt, res.intern ] # you have more work to do
      end
      res = res.upcase if res && all_caps_rx =~ x # the just be cute
      res
    end

    o[:oxford_comma] = -> a, ult = " and ", sep = ", " do
      (hsh = ::Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end

    inflected = {
        a: ['no ', 'a '],              # no birds  / a bird   / birds
       an: ['no ', 'an '],             # no errors / an error / errors
       is: ['exist', 'is', 'are'],
       no: ['no ', 'the only '],
        s: ['s', nil, 's'],
       _s: [ nil, 's' ],               # it requires, they require
     this: ['these', 'this', 'these'],
      was: ['were', 'was', 'were']
    }

    (norm = { 0 => 0, 1 => 1 }).default = 2

    o[:s] = -> a, v=:s do
      count = ::Numeric === a ? a : a.length # if float, watch what happens
      zero_one_two = norm[ count ]
      inflected.fetch(v)[ zero_one_two ]
    end

    o[:inflect] = -> func do
      inflect(& func )
    end

    def self.inflect &body                     # useful quick & dirty hack
      o = ::Object.new                         # for low-commitment inflection
      o.extend Headless::SubClient::InstanceMethods # so bad but u get the idea
      r = o.instance_exec(& body)
      r
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end
end
