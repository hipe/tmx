module Skylab::MyTerm::TestSupport

  module Stubs::Kernel_01_Hi

    _build_faked_out_kernel = Lazy_.call do

      ke = Home_::Invocation_Kernel___.new Home_::Models_

      inst = ke.silo :Installation

      o = TS_::Mess_With[ inst ]

      # when the controller asks for `fonts_dir`, give it this string:

      o.redefine_as_memoized :fonts_dir do
        '/talisker'
      end

      # when the thing globs on that dir, give it these paths

      o.replace_with_partially_stubbed_proxy :filesystem do |fs|

        fs.if_then :glob, '/talisker/*' do
          [
            '/talikser/wazoozle.dfont',
            '/talisker/I_AM_a_font.dfont',
          ]
        end
      end

      _sc = TS_::Stubs::System_Conduit_01_Hi.instance

      inst.system_conduit = _sc

      ke
    end

    define_singleton_method :instance, Lazy_.call( & _build_faked_out_kernel )
  end
end
# #tombstone: early prototype of the state pattern
# #tombstone: a persistence graph
# #tombstone: tmpdir
