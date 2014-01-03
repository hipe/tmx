module Skylab::TestSupport::Regret::API

  class API::Actions::Intermediates::Templo < API::Support::Templo_

    def initialize wlk, pn
      @render_to_p = -> io do

        local_pn = wlk.class.subtract pn , wlk.top_pn
        local_a = local_pn.sub_ext( '' ).to_s.split ::Pathname::SEPARATOR_LIST
        'test-support' == (s = local_a.pop) or
          fail "sanity - test support? #{ s }"
        'test' == (s = local_a.fetch 1 ) or fail "sanity - test? #{ s }"
        local_a[ 1 ] = nil ; local_a.compact!
        loc_a = local_a.dup
        cur_mod = wlk.top_mod
        cur_a = [ cur_mod.to_s.intern ]
        count = 0
        step = -> do
          i, mod = MetaHell::Boxxy::Resolve_name_and_value[ :from_module, cur_mod, :path_x, loc_a.fetch( 0 ) ]
          cur_a.push i
          loc_a.shift
          loc_a.length.zero? and break( step = nil )
          count += 1
          cur_mod = mod
        end
        amod = bmod = cmod = bles = requ = nil
        step[]
        amod = cur_a.join '::'
        cr_a = cur_a
        cur_a = []
        step[] while step
        if cur_a.length.zero?
          requ = "require_relative ../core\n\n"
          bles = '::Skylab::TestSupport::Regret'
          cmd = cr_a.fetch( -1 )
        else
          requ = "require_relative '../test-support'\n\n"
          cmd = cur_a.fetch( -1 )
          cmod = "::#{ cmd }"
          bles = "::#{ amod }::TestSupport"
          if cur_a.length != 1
            bmod = "::#{ cur_a[ 0 .. -2 ] * '::' }"
          end
          bles = "::#{ amod }::TestSupport#{ bmod }"
        end
        bt, = get_templates :_body
        io.write bt.call(
          requ: requ,
          amod: amod,
          bmod: bmod,
          cmod: cmod,
          bles: bles,
          cmd: cmd
        )
        true
      end
    end
  end
end
