require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - help screen integration" do

    extend TS_
    use :CLI_isomorphic_methods_client

    context "ctx" do

      it "basic help screen gets usage and options" do

        invoke 'wammo', '--hel'
        _str = flush_to_unstyled_string_contiguous_lines_on_stream :e
        _str.should eql <<-HERE.unindent
          usage: zeepo wammo
                 zeepo wammo -h

          options
                  --flim[=foo]                 flam.
              -h, --help                       this screen
        HERE
        expect_succeeded
      end

      dangerous_memoize_ :client_class_ do

        class CLI_IMC_06 < subject_class_

          option_parser do | op |

            op.on '--flim[=foo]', 'flam.' do |x|
              @_par_x_a_.push :flim, x ; nil
            end
          end

          def wammo
          end
          self
        end
      end
    end
  end
end
