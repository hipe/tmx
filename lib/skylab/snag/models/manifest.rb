module Skylab::Snag

  module Models::Manifest

    class << self

      def build_file pathname
        self::File__.new pathname
      end

      def header_width
        HEADER_WIDTH__
      end
      HEADER_WIDTH__ = '[#867] '.length

      def line_width
        LINE_WIDTH__
      end
      LINE_WIDTH__ = 80
    end
  end
end
