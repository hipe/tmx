module Skylab::BeautySalon

  class CrazyTownMagnetics_::Result_via_ReportName < Common_::MagneticBySimpleModel

    begin

      attr_writer(
        :listener,
        :report_name,
      )

      def execute
        @_report_name_symbol = remove_instance_variable( :@report_name ).gsub( DASH_, UNDERSCORE_ ).intern
        if :list == @_report_name_symbol
          __when_list
        else
          __when_item
        end
      end

      def __when_list

        # (there's a thing we have a thing for but meh, meh meh)

        _dir = Home_::CrazyTownReports_.dir_path

        a = ::Dir[ ::File.join( _dir, '*' ) ]

        if a.length.zero?
          @listener.call( :info, :expression ) { |y| y << "(no results)" }
        end

        Stream_.call a do |path|
          basename = ::File.basename path
          d = ::File.extname( basename ).length
          d.zero? ? basename : basename[ 0 ... -d ]
        end
      end
    end
  end
end
# #born
