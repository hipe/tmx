module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Intermediates

        class View_Controller__

          def initialize const_a, templates
            @const_a = const_a
            @template = templates.template :_body
          end

          def execute

            _requ = "require '../test-support'#{ NEWLINE_ }#{ NEWLINE_ }"

            d = @const_a.length

            if 2 < d

              amod = @const_a[ 0, 2 ] * CONST_SEP_

              if 3 < d

                cmod = "#{ CONST_SEP_ }#{ @const_a.last.id2name }"

                if 4 < d

                  bmod = [ nil, * @const_a[ 3 .. -2 ] ] * CONST_SEP_

                end
              end

              _bles = [ nil, @const_a[ 0 .. -2 ] ] * CONST_SEP_
            end

            _whole_string = @template.call(
              requ: _requ,
              amod: amod,
              bmod: bmod,
              cmod: cmod,
              bles: _bles )

            TestSupport_._lib.basic::String.line_stream _whole_string
          end
        end
      end
    end
  end
end
