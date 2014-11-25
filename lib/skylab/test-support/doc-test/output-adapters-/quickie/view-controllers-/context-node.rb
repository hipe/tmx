module Skylab::TestSupport

  module Regret::API

  module Actions::DocTest::Templos__::Quickie::Context__

    Context__ = self

    module Part_

      def self.resolve_parts blk, y
        case blk.snippet_a.length
        when 0 ; EMPTY_A_
        when 1 ; [ build_example( blk.snippet_a.fetch( 0 ), y ) ]
        else   ; Context__::Beforer_.build_parts blk, y
        end
      end

      def self.build_example snippet, y
        Example_.new( y ) do |e|
          e.quoted_description_string =
            API_::Support::Templo_.descify snippet.last_other
          filter = Actions::DocTest::Templos__::Predicates.new
          snippet.line_a.each( & filter.method( :<< ) )
          e.local_lines = filter.flush
        end
      end
    end

    module Part_

      class Part__

        class << self ; alias_method :orig_new, :new end

        def self.new i
          ::Class.new( self ).class_exec do
            class << self ; alias_method :new, :orig_new end
            define_method :template_i do i end
            self
          end
        end

        def initialize y
          @y = y.call
          yield self
          @local_lines or fail "sanity - local lines?"
          nil
        end

        attr_accessor :local_lines

        def indented_code_string
          @local_lines.each( & @y.method( :puts ) )
          @y.flush
        end
      end

      class Before_ < Part__.new :before

      end

      class Example_ < Part__.new :example

        attr_accessor :quoted_description_string

      private

        def initialize y
          super
          @quoted_description_string or fail "sanity - desc?"
          freeze
          nil
        end
      end
    end
  end
  end
end
