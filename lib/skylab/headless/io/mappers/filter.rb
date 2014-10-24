module Skylab::Headless

  module IO

    module Mappers

      Autoloader_[ Interceptors_ = self ]  # ~ stowaway, a.l needed in this file!

      class Filter  # :[#159]

    # intercept write-like messages intended for an ::IO, but do something
    # magical with the content. Don't forget to call flush! at the end.

        Headless_::Lib_::Entity[ self, -> do

          o :iambic_writer_method_name_suffix, :'='

          def line_begin_string=
            s = iambic_property
            s and set_line_begin_proc -> { @downstream_IO.write s }
          end

          def line_begin_proc=
            p = iambic_property
            p and set_line_begin_proc p
          end

          def line_end_proc=
            p = iambic_property
            p and set_line_end_proc p
          end

          def puts_map_proc=

            # each data passed to puts will first be run through each filter
            # in the order received in a reduce operation, the result being
            # what is finally passed to puts

            p = iambic_property
            p and ( @puts_map_p_a ||= [] ).push p
          end

          o :properties,
            :downstream_IO,
            :niladic_pass_filter_proc

        end ]

        include Interceptors_::Tee::Is_TTY_Instance_Methods

        def initialize * x_a

          @check_for_line_boundaries = @line_begin_p = @line_end_p =
            @niladic_pass_filter_proc = @puts_map_p_a = nil

          @prev_was_NL = true

          if 1 == x_a.length
            x_a.unshift :downstream_IO
          end

          process_iambic_fully x_a

          @niladic_pass_filter_proc ||= NILADIC_TRUTH_

        end

        def downstream_IO
          @downstream_IO
        end

        %i( close closed? rewind truncate ).each do |i|
          define_method i do |*a|
            if @downstream_IO.respond_to? i
              @downstream_IO.send i, *a
            end
          end
        end

        def puts *a
          if do_pass
            do_puts_via_a a
          end
        end

        def << str
          if do_pass
            do_write str
          end
          self
        end

        def write str
          if do_pass
            do_write str
          else
            "#{ str }".length
          end
        end

      private

        def set_line_begin_proc p
          set_line_proc :@line_begin_p, p ; nil
        end

        def set_line_end_proc p
          set_line_proc :@line_end_p, p ; nil
        end

        def set_line_proc ivar, p
          instance_variable_set ivar, p
          @check_for_line_boundaries = true ; nil
        end

    def do_puts_via_a a
      a = a.flatten
      a.length.zero? and a.push EMPTY_S_
      a.each do |s|
        if @puts_map_p_a
          s = @puts_map_p_a.reduce( s ) { |m, p| p[ m ] }
        end
        s = s.to_s
        if NEWLINE_CHAR__ != s.getbyte( -1 )
          s = "#{ s }#{ NEWLINE_ }"
        end
        do_write s  # route everything through write()
      end
      nil  # per ::IO#puts, but consider it undefined.
    end
    NEWLINE_CHAR__ = NEWLINE_.getbyte 0

    def do_write str
      begin
        if str.length.zero? || ! @check_for_line_boundaries
          break(( length = @downstream_IO.write str ))
        end
        was_NL = @prev_was_NL
        @prev_was_NL = NEWLINE_ == str[ -1 ]
        a = str.split NEWLINE_, -1
        last_d = a.length - 1
        a.each_with_index do |s, d|
          is_not_first = d.nonzero?
          is_not_last = last_d != d
          has_width = s.length.nonzero?
          if is_not_first
            @downstream_IO.write NEWLINE_
            @line_end_p and @line_end_p[]
          end
          if is_not_first || was_NL and
            is_not_last || has_width and @line_begin_p
            @line_begin_p[]
          end
          if has_width
            @downstream_IO.write s
          end
        end
        length = str.length
      end while nil
      length
    end

        def do_pass
          @niladic_pass_filter_proc.call
        end
      end
    end
  end
end
