module Skylab::Git

  module Models::FileOperations

    These__ = ::Class.new

    class Create < These__

      def initialize path
        @path = path
      end

      def to_summary
        "create #{ @path }"
      end

      attr_reader(
        :path,
      )

      def category_symbol
        :create
      end

      def is_create
        true
      end
    end

    class Change < These__

      def initialize path
        @path = path
      end

      def to_summary
        "change #{ @path }"
      end

      attr_reader(
        :path,
      )

      def category_symbol
        :change
      end

      def is_change
        true
      end
    end

    class Rename < These__

      def initialize from_path, to_path
        @from_path = from_path
        @to_path = to_path
      end

      def to_summary
        "rename #{ @from_path } #{ @to_path }"
      end

      def path
        @from_path  # eek
      end

      attr_reader(
        :from_path,
        :to_path,
      )

      def category_symbol
        :rename
      end

      def is_rename
        true
      end
    end

    class Delete < These__

      def initialize path
        @path = path
      end

      def to_summary
        "delete #{ @path }"
      end

      attr_reader(
        :path,
      )

      def category_symbol
        :delete
      end

      def is_delete
        true
      end
    end

    class These__
      def is_change
        false
      end
      def is_create
        false
      end
      def is_delete
        false
      end
      def is_rename
        false
      end
    end
  end
end
# #history: abstracted from one-off
