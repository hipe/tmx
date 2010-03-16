module Hipe
  module Assess
    module Proto
      module Type
        class << self
          def of_string str
            unless str.kind_of? ::String
              raise TypeError.new("need String had #{str.inspect}")
            end
            case str
            when Empty::Pattern then Empty
            when Integer::Pattern then Integer
            when Float::Pattern then Float
            else String
            end
          end
        end
        module Type
          def self.extended foo
            unless foo.instance_variable_defined?('@can_be_represented_with')
              the_set = Set.new([foo]) # every type can represent itself
              foo.instance_variable_set('@can_be_represented_with',the_set)
            end
          end
          ReForToSym = /([^:]+)$/
          def to_sym
            ReForToSym.match(to_s)[1].downcase.intern
          end
          def can_be_represented_with *args
            if ! args.any?
              @can_be_represented_with
            else
              dont_have = @can_be_represented_with - args
              dont_have.each do |foo|
                @can_be_represented_with.add foo
              end
            end
          end
          def can_be_represented_with? foo
            @can_be_represented_with.include? foo
          end
        end
        module String
          extend Type
        end
        module Float
          extend Type
          can_be_represented_with String
          Pattern = /\A-?\d+(?:\.\d+)?\Z/
        end
        module Integer
          extend Type
          can_be_represented_with Float
          Pattern = /\A\d+\Z/
        end
        module Empty
          extend Type

          # i guess. i dunno.  probably not important
          can_be_represented_with Float, String, Integer


          Pattern = /\A[[:space:]]*\Z/
        end
      end
    end
  end
end
