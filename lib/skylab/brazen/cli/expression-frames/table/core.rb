module Skylab::Brazen

  module CLI::Expression_Frames::Table

    class << self

      def express_minimally_into y, opt_h=EMPTY_H_, h_a

        Express_table_minimally___[ y, opt_h, h_a ]
      end
    end  # >>

    Express_table_minimally___ = -> y, opt_h, h_a do  # [#096.A]

    # for expressing a simple table minimally:
    #
    #     self._TODO: reverse write
    #
    #     y = Brazen_::CLI::Expression_Frames::Table.express_minimally_into [],
    #       [ food: 'donuts', drink: 'coffee' ], -> line { y << line } )
    #
    #     y.shift   # => "|   Food  |   Drink |"
    #     y.shift   # => "| donuts  |  coffee |"
    #     y.length  # => 0
    #

      opt_h = { show_header: true }.merge opt_h

      sym_a = []

      max_h = ::Hash.new { | h, k | sym_a.push( k ) ; h[ k ] = 0 }

      h_a.each do |row|
        row.each { |k, v| (l = v.to_s.length) > max_h[k] and max_h[k] = l }
      end

      if opt_h[ :show_header ]

        label_p = -> k do
          s = k.to_s.gsub( UNDERSCORE_, SPACE_ ).capitalize
          s.length > max_h[ k ] and max_h[ k ] = s.length
          s
        end

        h_a = [::Hash[ sym_a.map{ |k| [ k, label_p[k] ] } ]] + h_a.to_a
      end

      left = '| ' ; sep = '  |  ' ; right = ' |'

      h_a.each do | h |
        y << "#{ left }#{
          sym_a.map{ | k | "%#{ max_h[ k ] }s" % h[ k ].to_s }.join sep
        }#{ right }"
      end

      y
    end

    EMPTY_H_ = {}.freeze
  end
end
