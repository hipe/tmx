module Skylab::Snag

  class Models::Manifest

    class Node_Scan__ < Agent_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :absorber, :absorb_iambic_fully,
        :field_i_a, [ :flyweight, :error_p, :info_p ] ]

      def initialize any_pathname, manifest_file_p
        @pathname = any_pathname
        @manifest_file_p = manifest_file_p
        @enum_class = Snag_::Models::Node::Enumerator
      end

      def filter! p
        get_enum.filter! p
      end

      def valid
        get_enum.valid
      end

    private

      def get_enum
        @enum_class.new( & method( :visit ) )
      end

      def visit y
        r = nil
        begin
          @y = y
          r = prepare or break
          r = execute
        end while nil
        r
      end

      def prepare
        -> do  # #result-block
          @pathname or break bork( "manifest pathname was not resolved" )

          # if pathname is resolved (i.e. we know what it *should* be)
          # and it doesn't exist, there are simply no items to list.

          @pathname.exist? or break info( "manifest file didn't exist -#{
            } no issues." )

          @node_flyweight ||= Models::Node.build_flyweight @pathname

          @manifest_file = @manifest_file_p[] or break @manifest_file

          true
        end.call
      end

      def execute
        caught_item = catch :last_item do  # all throwing will be eliminated [#035]
          @node_flyweight.
            each_node @manifest_file.normalized_line_producer, @y
          nil
        end
        if ! caught_item then true else
          handle_caught_item caught_item
        end
      end

      def handle_caught_item item
        # file will have been closed IFF the caught one was the last one.
        @manifest_file.release_early if @manifest_file.open?
        throw :last_item, item
      end
    end
  end
end
