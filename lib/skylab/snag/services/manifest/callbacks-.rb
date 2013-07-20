module Skylab::Snag

  class Services::Manifest

    class Callbacks_

      # callbacks is also immediate values for those values that
      # are immediate. so it both a proxy and a request structure.

      MEMBER_A_ = [
        :render_lines_p, :curry_enum_p, :manifest_file_p, :pathname,
        :file_utils_p, :tmpdir_p
      ].freeze

      MetaHell::FUN.fields[ self, * MEMBER_A_ ]

      attr_reader( * MEMBER_A_ )

      def render_line_a node, *identifier_d
        @render_lines_p[ node, *identifier_d ]
      end

      def get_subset_a
        h = self.class::BASIC_FIELDS_H_
        SUBSET_A_.reduce [] do |m, i|
          m << i << instance_variable_get( h.fetch i )
        end
      end

      intrinsic = [ :render_lines_p, :curry_enum_p ]

      SUBSET_A_ = ( MEMBER_A_ - intrinsic ).freeze

      def curry_enum *a
        @curry_enum_p[ *a ]
      end
    end
  end
end
