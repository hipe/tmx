module Skylab::Slicer

  Actors_ = ::Module.new

  module Actors_::Determine_and_distribute_medallions ; class << self

    def [] ss_a

      rx = /(?:_|(?=[0-9]))/  # only for 2

      first_try = -> ss do

        s_a = ss.stem.split rx, 2
        if 1 == s_a.length
          s_a.first[ 0, 2 ]
        else
          s_a.map { |s| s[ 0 ] }.join EMPTY_S_
        end
      end

      h = ::Hash.new { |h_, k| h_[ k ] = [] }

      ss_a.each do | ss |
        _medo = first_try[ ss ]
        h[ _medo ].push ss
      end

      __enumerator_via h, ss_a
    end

    def __enumerator_via h, ss_a

      ::Enumerator.new do | y |

        resolve_conflict = -> ss_a_ do
          d = 3
          ss_a_.each do | ss |
            ss.sigil = ss.const.id2name[ 0, d ].downcase
            y << ss
          end
          nil
        end

        h.each_pair do | medo, ss_a_ |
          if 1 == ss_a_.length
            ss = ss_a_.first
            ss.sigil = medo
            y << ss
          else
            resolve_conflict[ ss_a_ ]
          end
        end
      end
    end ; end
  end
end
