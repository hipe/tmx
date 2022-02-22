module Skylab::System

  module Filesystem::UbuntuPathSorter__

    # When we're on Ubuntu, we want to sort the paths the way OS X does
    # (for historical reasons). This takes a surprising amount of work.

    Maybe_sort_filesystem_paths = -> paths do
      paths.sort_by do |path|
        PathForUseInComparison___.new path
      end
    end

    Maybe_sort_filesystem_entries = -> entries do
      sep = ::File::SEPARATOR
      entries.sort_by do |entry|
        if entry.include? sep
          fail "oops: not an entry, has separator: #{entry}"
        end
        EntryForUseInComparison__.new entry
      end
    end

    class PathForUseInComparison___

      def initialize path
        pcs = path.split ::File::SEPARATOR, -1
        @parts = pcs.map { |pc| EntryForUseInComparison__.new pc }
        @length = @parts.length
      end

      def <=> other
        left_len, right_len = @length, other.length
        left_parts, right_parts = @parts, other.parts

        left_i, right_i = 0, 0
        left_i < left_len or fail
        right_i < right_len or fail
        begin
          cmp = left_parts[left_i] <=> right_parts[right_i]
          # If you encounter a path component that is not the same, done
          if 0 != cmp
            return cmp
          end
          # The path components are the same at that point. Advance
          left_i +=1
          right_i += 1
          if left_len == left_i
            if right_len == right_i
              # You have reached the end of both. They must be the same.
              return 0
            end
            # You have reached the end of the left one but the right one
            # still has components. Something comes after nothing
            return -1
          end
          if right_len == right_i
            # You have reached the end of the right one but the left one
            # still has components. Switch them because something comes after..
            return 1
          end
          # Now each side still has components to compare. recurse
          redo
        end while above
        never
      end

      attr_reader :parts, :length
    end

    class EntryForUseInComparison__
      def initialize entry
        @string = entry
        @casing_category = nil
      end

      def <=> other
        # OS X sees uppercase as coming *after* lowercase.
        if casing_category == other.casing_category
          return @string <=> other.string
        end
        if is_LC
          if other.is_UC
            -1  # [LC, UC] => correct order
          else
            1  # [LC, other] => flip it
          end
        elsif is_UC
          if other.is_LC
            1  # [UC, LC]  => flip it
          else
            1  # [UC, other] => flip it. hi.
          end
        else
          other.is_LC || other.is_UC or fail
          -1  # [other, letter] => correct order (covered)
        end
      end

      def is_LC
        :lowercase_category == casing_category
      end

      def is_UC
        :uppercase_category == casing_category
      end

      def casing_category
        if @casing_category.nil?
          @casing_category = Determine_casing_category__[@string]
        end
        @casing_category
      end

      attr_reader :string
    end

    Determine_casing_category__ = -> s do
      md = /^(?:(?<is_lower>[a-z])|(?<is_upper>[A-Z])|(?:.|$))/.match s
      if not md
        raise "oops, didn't expect an entry like this: #{s.inspect}"
      end
      if md[:is_lower]
        :lowercase_category
      elsif md[:is_upper]
        :uppercase_category
      else
        :other_category
      end
    end
  end
end
# #born
