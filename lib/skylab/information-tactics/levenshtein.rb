module Skylab::InformationTactics

  # levenshtein distance
  # is kind of amazing
  #
  #     A_ = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
  #     a = InformationTactics::Levenshtein::Closest_n_items_to_item[ 3, A_, :bernono ]
  #
  #     a  # => [ :onono, :ernana, :banana ]

  module Levenshtein

    InformationTactics::Library_.kick :Levenshtein

    Closest_n_items_to_item = -> closest_n, pool_a, outside_x do  # #curry-friendly
      outside_s = outside_x.to_s

      item_a = pool_a.reduce [] do |m, x|
        dist_d = ::Levenshtein.distance x.to_s, outside_s
        m << Item__[ x, dist_d ]
      end

      item_a.sort_by!( & :distance_d )
      item_a[ 0, closest_n ].map( & :x )
    end
    #
    Item__ = ::Struct.new :x, :distance_d
  end
end
