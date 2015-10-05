module Skylab::Slicer

  Actors_ = ::Module.new

  module Actors_::Determine_and_distribute_medallions ; class << self

    def [] ss_a

      rx = /\A([A-Z])(?:[a-z_]*)([A-Z0-9])/

      first_try = -> const_s do
        md = rx.match const_s
        if md
          "#{ md[ 1 ] }#{ md[ 2 ] }".downcase
        else
          const_s[ 0, 2 ].downcase
        end
      end

      h = ::Hash.new { |h_, k| h_[ k ] = [] }

      ss_a.each do | ss |
        _medo = first_try[ ss.const.id2name ]
        h[ _medo ].push ss
      end

      __enumerator_via h, ss_a
    end

    def __enumerator_via h, ss_a

      ::Enumerator.new do | y |

        resolve_conflict = -> ss_a_ do
          d = 3
          ss_a_.each do | ss |
            ss.medo = ss.const.id2name[ 0, d ].downcase
            y << ss
          end
          nil
        end

        h.each_pair do | medo, ss_a_ |
          if 1 == ss_a_.length
            ss = ss_a_.first
            ss.medo = medo
            y << ss
          else
            resolve_conflict[ ss_a_ ]
          end
        end
      end
    end ; end
  end
end
