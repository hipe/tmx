module Skylab::InformationTactics

  # levenshtein distance
  # is kind of amazing
  #
  #     A_ = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
  #     a = InformationTactics::Levenshtein_[ 3, A_, :bernono ]
  #
  #     a  # => [ :onono, :ernana, :banana ]

  module Levenshtein_

    InformationTactics::Services.kick :Levenshtein

    P_ = -> closest_n, pool_a, outside_x do  # #curry-friendly
      outside_s = outside_x.to_s

      item_a = pool_a.reduce [] do |m, x|
        dist_d = Levenshtein.distance x.to_s, outside_s
        m << Item_[ x, dist_d ]
      end

      item_a.sort_by!( & :distance_d )
      item_a[ 0, closest_n ].map( & :x )
    end

    Item_ = ::Struct.new :x, :distance_d

    define_singleton_method :[], & P_

  end
end
