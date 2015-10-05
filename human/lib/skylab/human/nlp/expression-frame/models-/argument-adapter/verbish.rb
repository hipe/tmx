module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Argument_Adapter

      class Verbish < self

        class << self
          def new_via__polymorphic_upstream__ st

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

        def initialize
          super
        end

        attr_reader :lemma_string

        def __init_via_string s
          @lemma_string = s
        end

        def slot_symbol
          :verb_argument
        end
      end
    end
  end
end
