module Hipe
  module Assess
    module CodeBuilder

      #
      # any nodes that want to can register themselves with this
      # (typically in the constructor) so that other nodes can refer to them
      # by id.  (note that garbage collection will not reclaim these nodes
      # unless they assume responsibility for nilling this out somehow)
      #
      Nodes = Array.new
      class << Nodes
        def register obj
          id = length
          self[id] = obj
          id
        end
      end

      def module_name_sexp str
        str = str.to_s
        if str.nil?
          nil
        elsif str.include?(':')
          parser.process str
        else
          sym = str.to_sym
          s(:const, sym)
        end
      end

      def const_get_deep name
        name.split(/::/).inject(Object) { |k, n| k.const_get n }
      end

      #
      # shadows Assess::BracketExtender
      #
      module BracketExtender
        def [] item
          unless item.kind_of?(Sexp)
            msg = "Can't turn #{item}:#{item.class} into a #{self}"
            fail(msg)
          end
          item.extend self unless item.kind_of? self
          item
        end
      end
    end
  end
end
