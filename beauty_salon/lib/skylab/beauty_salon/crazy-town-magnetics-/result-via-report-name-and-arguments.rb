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

        @report_name ||= "main"

        @_report_name_symbol = remove_instance_variable( :@report_name ).gsub( DASH_, UNDERSCORE_ ).intern

        @_dir = Home_::CrazyTownReports_.dir_path

        if :list == @_report_name_symbol
          __when_list
        else
          __when_item
        end
      end

      def __when_list

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

      def __when_item

        _sym = remove_instance_variable :@_report_name_symbol
        _const = Common_::Name.via_variegated_symbol( _sym ).as_camelcase_const_string
        _class = Home_::CrazyTownReports_.const_get _const, false
        _class.call_by do |o|

          THESE___.each_pair do |write_m, read_m|  # kewel new pattern
            if o.respond_to? write_m
              o.send write_m, send( read_m )
            end
          end
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
  end
end
# #born
