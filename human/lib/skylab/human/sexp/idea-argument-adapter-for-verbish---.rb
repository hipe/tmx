module Skylab::Human

  module Sexp

    class Idea_Argument_Adapter_for_Verbish___ < Idea_Argument_Adapter_
      # -
        class << self
          def via__argument_scanner__ st

            new do

              x = st.gets_one
              if x.respond_to? :ascii_only?
                __init_via_string x
              else
                self._FUN
              end
            end
          end
        end  # >>

        attr_reader :lemma_string

        def __init_via_string s
          @lemma_string = s
        end

        def slot_symbol
          :verb_argument
        end
      # -
    end
  end
end
