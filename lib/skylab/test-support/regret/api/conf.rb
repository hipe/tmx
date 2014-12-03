module Skylab::TestSupport

  module Regret::API

  module Conf

    Verbosity = TestSupport_::Verbosity_.produce_conf_module [ :notice, :medium, :murmur ]
    # NOTE the order of the symbols above corresponds to the number of "-v"'s !

    def self.[] i
      const_get "#{ i.upcase }_", false
    end

    rx = /\A([A-Z_]*[A-Z])_\z/
    constants.each do |i|
      if (( md = rx.match i ))
        define_singleton_method md[1].downcase do
          const_get i, false
        end
      end
    end
  end
  end
end
