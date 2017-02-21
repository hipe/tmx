module Skylab::Basic

  module Pathname  # see [#004]

    class << self

      def description_under_of_path expag, path
        expag.calculate do
          pth path
        end
      end

      def expand_real_parts_by_relative_parts real_parts, rel_parts, sep=File::SEPARATOR, & oes_p

        a = real_parts.dup
        ok = true

        rel_parts.length.times do | d |
          s = rel_parts.fetch d
          if DOT_DOT_ == s
            if a.length.zero?
              ok = when_dot_dot_error real_parts, rel_parts, sep, & oes_p
              ok or break
            else
              a.pop
            end
          else
            a.push s
          end
        end

        ok ? a : ok
      end

    private

      def when_dot_dot_error real_parts, rel_parts, sep, & oes_p
        if oes_p
          oes_p.call :error, :cannot_go_higher_than_top do
            build_dot_dot_event real_parts, rel_parts, sep
          end
        else
          raise build_dot_dot_event( real_parts, rel_parts, sep ).to_exception
        end
      end

      def build_dot_dot_event real_parts, rel_parts, sep

        Common_::Event.inline_not_OK_with :cannot_go_higher_than_top,
            :real_parts, real_parts, :rel_parts, rel_parts, :sep, sep do | y, o |

          _s = o.real_parts.join o.sep
          _s_ = o.rel_parts.join o.sep

          y << "cannot go higher than top. meaningless path: #{
            } #{ ick "#{ _s }#{ o.sep }#{ _s_ }" }"

        end
      end

    public

      def identifier * a
        if a.length.zero?
          Identifier__
        else
          Identifier__.new( * a )
        end
      end

      def members
        singleton_class.public_instance_methods( false ) - [ :members ]
      end

      def normalization
        Pathname::Normalization__
      end

      def try_convert x
        x and begin
          if x.respond_to? :relative_path_from
            x
          elsif x.respond_to? :to_path
            Home_.lib_.pathname.new x.to_path
          else
            Home_.lib_.pathname.new x
          end
        end
      end
    end  # >>

    class Identifier__  # you might prefer [#sy-003] the FS byte upstream ID

      def initialize io=nil, path_x

        @_IO = io

        @path = if path_x.respond_to? :to_path
          path_x.to_path
        else
          path_x
        end
      end

      attr_reader :path

      def modality_const  # :+#experimental
        :ByteStream
      end

      def description_under expag
        Pathname_.description_under_of_path expag, @path
      end

      def to_simple_line_stream
        @_IO
      end

      def to_minimal_yielder
        @_IO
      end
    end

    # ==

    Relative_path_from = -> subject_path, reference_path do

      cls = Home_.lib_.pathname
      _ref_pn = cls.new reference_path
      _sub_pn = cls.new subject_path
      _res_pn = _sub_pn.relative_path_from _ref_pn
      _res_pn.to_path
    end

    # ==

    tailerer = Lazy_.call do
      Home_::String::Tailerer_via_separator[ ::File::SEPARATOR ]
    end

    Localizer = -> root, & else_p do

      # somewhat like `::Pathname#relative_path_from` with an assertion

      tailerer[][ root, & else_p ]
    end

    Path_matches_directory = -> path, dir do  # assume..

      # assume both paths are "fully normal", i.e they are absolute and they
      # do not end in a file separator. `path` "matches" `dir` IFF` `path`
      # points to a node that is inside `dir` or both point to the same node
      # (i.e are the same path).

      case dir.length <=> path.length

      when -1  # path is longer
        d = dir.length
        dir == path[ 0, d ] && FILE_SEPARATOR_BYTE_ == path.getbyte(d)

      when 0  # dir and path are same length
        dir == path

      when 1  # path is shorter
        false
      end
    end

    # ==

    DOT_DOT_ = '..'
    FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
    Pathname_ = self
  end
end
