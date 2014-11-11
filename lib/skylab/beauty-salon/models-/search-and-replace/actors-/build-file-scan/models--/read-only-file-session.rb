module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_file_scan

      class Models__::Read_Only_File_Session

        class << self

          def producer_via_iambic x_a
            Producer__.new do
              process_iambic_fully x_a
            end
          end
        end

        class Producer__

          Callback_::Actor.methodic self, :simple, :properties,

            :property, :ruby_regexp,
            :property, :do_highlight,
            :ignore, :max_file_size_for_multiline_mode,
            :property, :on_event_selectively


          def initialize
            @do_highlight = nil
            super
            @prototype = Self_.new @ruby_regexp, @do_highlight, @on_event_selectively
          end

          def produce_file_session_via_ordinal_and_path d, path
            @prototype.dup_with_ordinal_and_path d, path
          end
        end

        def initialize * a
          @ruby_regexp, @do_highlight, @on_event_selectively = a
          freeze
        end

        def dup_with_ordinal_and_path d, path
          dup.init_copy d, path
        end

      protected

        def init_copy d, path
          @ordinal = d
          @path = path
          freeze
        end

      public

        def members
          [ :ordinal, :path, :ruby_regexp ]
        end

        attr_reader :ordinal, :path, :ruby_regexp

        def to_read_only_match_scan
          io = ::File.open @path, READ_MODE_
          line_number = 0
          rx = @ruby_regexp
          match = Read_Only_Match__.new @path, @do_highlight
          Callback_.scan do
            while line = io.gets
              line_number += 1
              md = rx.match line
              if md
                x = match.dup_with_args md, line_number, line
                break
              end
            end
            x
          end
        end

        class Read_Only_Match__

          def initialize *a
            @path, @do_highlight = a
            freeze
          end

          def dup_with_args * a
            dup.init_copy a
          end

         protected

           def init_copy a
             @md, @line_number, @line = a
             freeze
           end

         public

          def members
            [ :md, :line_number, :line, :path ]
          end

          attr_reader :md, :line_number, :line, :path

          def render_line
            if @do_highlight
              render_highlighted_line
            else
              render_black_and_white_line
            end
          end

          def render_highlighted_line
            begn, nxt = @md.offset 0
            first_part = @line[ 0 ... begn ]
            match_part = @line[ begn ... nxt ]
            last_part = @line[ nxt .. -1 ]
            "#{ @path }:#{ @line_number }:#{ first_part }\e[1;32m#{ match_part }\e[0m#{ last_part }"
          end

          def render_black_and_white_line
            "#{ @path }:#{ @line_number }:#{ @line }"
          end
        end

        Self_ = self
      end
    end
  end
end
