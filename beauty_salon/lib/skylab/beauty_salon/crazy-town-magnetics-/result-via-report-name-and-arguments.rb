module Skylab::BeautySalon

  class CrazyTownMagnetics_::Result_via_ReportName_and_Arguments < Common_::MagneticBySimpleModel

    # -

      attr_writer(
        :code_selector_string,
        :file_path_upstream,
        :filesystem,
        :listener,
        :replacement_function_string,
        :report_name,
      )

      def execute

        @_dir = Home_::CrazyTownReports_.dir_path

        s = remove_instance_variable :@report_name

        if s

          md = %r(\A
            (?<list>list)
            |
            (?: help (?: : (?<help_arg> .+ ) )? )
          \z)x.match s

          if md
            arg = md[ :help_arg ]
            if arg
              __when_help_with_arg arg
            elsif md[ :list ]
              _when_list
            else
              __when_help_with_no_arg
            end
          else
            _when_item _symbol_via_slug s
          end
        else
          _when_item :main
        end
      end

      def __when_help_with_no_arg

        # function soup to duplicate something we've done a number of times
        # before: print out the first few lines of the description lines of
        # each report. this does not do two-pass, so there is no "column".

        is_subsequent = -> { is_subsequent = -> { true } ; false }

        _when_list.expand_by do |slug|

          a = []
          if is_subsequent[]
            a.push EMPTY_S_
          end

          _write_description_lines_into a, 3, slug

          Stream_[ a ]
        end
      end

      def __when_help_with_arg arg

        lines = _write_description_lines_into [], arg
        if lines
          Stream_[ lines ]
        end
      end

      def _write_description_lines_into y, num=nil, slug

        cls = _class_via_symbol _symbol_via_slug slug
        if cls
          __do_write_desc_lines_into y, num, cls, slug
        end
      end

      def __do_write_desc_lines_into y, num, cls, slug

        last = nil
        recv_normally = -> s do
          y << last
          last = s
        end
        recv = -> s do
          recv = recv_normally
          last = s
        end

        reached_limit = if num
          0 < num || sanity
          countdown = num + 1
          -> do
            ( countdown -= 1 ).zero?
          end
        else
          EMPTY_P_
        end

        fmt = nil
        subsequent_line = -> s do
          recv[ fmt % s ]
        end
        p = -> s do
          fmt = "  %#{ slug.length }s  %s"
          recv[ fmt % [ slug, s ] ]
          fmt = fmt % CLEVER___
          p = subsequent_line
        end

        did_reach_limit = false
        _y = ::Enumerator::Yielder.new do |s|
          if reached_limit[]  # before adding line so we know that there were more
            did_reach_limit = true
            throw :_BS_yuck_
          end
          p[ s || EMPTY_S_ ]
        end

        catch :_BS_yuck_ do
          cls.describe_into_under _y, :_no_expag_yet_bs_
        end

        if did_reach_limit
          last = if /\.$/ =~ last
            "#{ last }."
          else
            "#{ last }.."
          end
        end

        y << last
      end

      CLEVER___ = [ EMPTY_S_, '%s' ]

      def _symbol_via_slug s
        s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def _when_list

        # (there's a thing we have a thing for but meh, meh meh)

        a = ::Dir[ ::File.join( @_dir, '*' ) ]

        if a.length.zero?
          @listener.call( :info, :expression ) { |y| y << "(no results)" }
        end

        Stream_.call a do |path|
          basename = ::File.basename path
          d = ::File.extname( basename ).length
          d.zero? ? basename : basename[ 0 ... -d ]
        end
      end

      def _when_item sym

        _class = _class_via_symbol sym

        _class.call_by do |o|

          THESE___.each_pair do |write_m, read_m|  # kewel new pattern
            if o.respond_to? write_m
              o.send write_m, send( read_m )
            end
          end
        end
      end

      def _class_via_symbol sym
        c = Common_::Name.via_variegated_symbol( sym ).as_camelcase_const_string
        if c
          _class = Home_::CrazyTownReports_.const_get c, false  # ..
          _class  # hi.
        else
          @listener.call( :error, :expression ) { |y| y << "bad report name" }
          UNABLE_
        end
      end

      # -- "report resources"

      THESE___ = {
        :code_selector_string= => :code_selector_string,
        :file_path_upstream_resources= => :__flush_file_path_upstream_resources,
        :listener= => :listener,
        :replacement_function_string= => :replacement_function_string,  # ..
      }

      # ~ (the above items correspond to the below method defs)

      def __flush_file_path_upstream_resources
        CrazyTownMagnetics_::DocumentSexpStream_via_FilePathStream.call_by do |o|
          o.file_path_upstream = remove_instance_variable :@file_path_upstream
          o.filesystem = @filesystem
          o.listener = @listener
        end
      end

      attr_reader(
        :code_selector_string,
        :listener,
        :replacement_function_string,
      )

      # --
    # -

    # ==

    # ==
    # ==
  end
end
# #born