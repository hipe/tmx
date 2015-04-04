module Skylab::Basic

  module Pathname  # see [#004]

    class << self

      def description_under_of_path expag, path
        expag.calculate do
          pth path
        end
      end

      def expand_real_parts_by_relative_parts real_parts, rel_parts, sep=FILE_SEP_, & oes_p

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

        Callback_::Event.inline_not_OK_with :cannot_go_higher_than_top,
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
            ::Pathname.new x.to_path
          else
            ::Pathname.new x
          end
        end
      end
    end  # >>

    class Identifier__

      def initialize io=nil, path_x

        @_IO = io

        @path = if path_x.respond_to? :to_path
          path_x.to_path
        else
          path_x
        end
      end

      def members
        [ :memers ] - self.class.instance_methods( false )
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

    DOT_DOT_ = ::Skylab::DOT_DOT_

    FILE_SEP_ = ::File::SEPARATOR

    Pathname_ = self
  end
end
