module Skylab::Headless
  module NLP
    module EN
      # forward declarations should be flattened as needed
    end
  end

  module NLP::EN::Minitesimal

    o = { }

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
     this: ['these', 'this', 'these']
    }

    (norm = { 0 => 0, 1 => 1 }).default = 2

    o[:s] = -> a, v=:s do
      count = ::Numeric === a ? a : a.length # if float, watch what happens
      zero_one_two = norm[ count ]
      inflected.fetch(v)[ zero_one_two ]
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze


    define_singleton_method :inflect do |&body| # useful quick & dirty hack
      o = ::Object.new                         # for low-commitment inflection
      o.extend Headless::SubClient::InstanceMethods # so bad but u get the idea
      r = o.instance_exec(& body)
      r
    end
  end
end
