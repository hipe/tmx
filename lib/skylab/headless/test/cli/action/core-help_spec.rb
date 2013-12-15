require_relative 'core-help/test-support'

module Skylab::Headless::TestSupport::CLI::Action::Hlp__

  describe "[hl] CLI action OP integration", ok: true do

    extend TS__

    context "mingle" do

      client_cls_with_op :Mingle do |op|

        op.on '--flim[=foo]', 'flam.' do |x|
          (( @_par_x_a_ ||= [] )) << :flim << x ; nil
        end

        op.on '-h', '--help' do
          enqueue :help ; nil
        end
      end

      it "basic help screen gets usage and options" do
        invoke '--hel'
        expect :styled, /\Ausage: yerp mingle #{
          }#{ ::Regexp.escape '[--flim[=foo]] [-h] [<arg> [..]]' }\z/
        expect ''
        expect :styled, 'options:'
        expect %r(\A[ ]{2,}--flim\[=foo\][ ]{2,}flam\.\z)
        expect %r(\A[ ]{2,}-h, --help\z)
        expect_succeeded
      end
    end
  end
end
