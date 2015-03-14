module Skylab::GitViz

  module Test_Lib_::Mock_System

    module Manifest_Entry_

      class FreeTag

        def initialize head, body
          head.frozen? or head = head.dup.freeze
          ! body or body.frozen? or body = body.dup.freeze
          @body_s = body ; @identifier_s = head
          @normal_stem_i = head[ 1 .. -1 ].gsub( DASH_, UNDERSCORE_ ).intern
          freeze
        end
        attr_reader :body_s, :normal_stem_i, :identifier_s

        def self.marshall a
          a.map do |ft|
            ft.marshall_with_no_spaces
          end * ' '
        end

        def marshall_with_no_spaces
          "#{ @normal_stem_i }=#{ @body_s || 'true' }"
        end
      end
    end
  end
end
