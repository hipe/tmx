module Skylab::TestSupport

  module Regret::API

  class Actions::Intermediates::Templo < TestSupport_::View_Controller_

    def initialize wlk, pn
      @render_to_p = -> io do

        local_pn = wlk.class.subtract pn , wlk.top_pn
        local_a = local_pn.sub_ext( EMPTY_S_ ).to_s.split FILE_SEP_
        'test-support' == (s = local_a.pop) or
          fail "sanity - test support? #{ s }"
        'test' == (s = local_a.fetch 1 ) or fail "sanity - test? #{ s }"
        local_a[ 1 ] = nil ; local_a.compact!
        loc_a = local_a.dup
        cur_mod = wlk.top_mod
        cur_a = [ cur_mod.to_s.intern ]
        count = 0
        step = -> do
          i, mod = Autoloader_.const_reduce do |cr|
            cr.from_module cur_mod
            cr.path_x loc_a.fetch 0
            cr.result_in_name_and_value
          end
          cur_a.push i
          loc_a.shift
          loc_a.length.zero? and break( step = nil )
          count += 1
          cur_mod = mod
        end
        amod = bmod = cmod = bles = requ = nil
        step[]
        amod = cur_a.join CONST_SEP_
        cr_a = cur_a
        cur_a = []
        step[] while step
        if cur_a.length.zero?
          requ = "require_relative ../core#{ NEWLINE_ }#{ NEWLINE_ }"
          bles = '::Skylab::TestSupport::Regret'
          cmd = cr_a.fetch( -1 )
        else
          requ = "require_relative '../test-support'#{ NEWLINE_ }#{ NEWLINE_ }"
          cmd = cur_a.fetch( -1 )
          cmod = "::#{ cmd }"
          bles = "::#{ amod }::TestSupport"
          if cur_a.length != 1
            bmod = "::#{ cur_a[ 0 .. -2 ] * CONST_SEP_ }"
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
end