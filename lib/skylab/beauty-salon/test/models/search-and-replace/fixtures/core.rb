module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  module Fixtures

    class << self

      def stfu_omg_function_file_path
        @soffp ||= stfu_omg_workspace_pathname.join( "#{ S_and_R_DOTFILE_ }/#{ FUNCTIONS_ }/stfu-omg.rb" ).to_path
      end

      def stfu_omg_workspace_path
        stfu_omg_workspace_pathname.to_path
      end

      def stfu_omg_workspace_pathname
        @sowp ||= Fixtures.dir_pathname.join( '00-has-hidden-workspace-with-stfu-omg-function' )
      end
    end

    FUNCTIONS_ = 'functions'.freeze

    S_and_R_DOTFILE_ = '.search-and-replace'.freeze

  end
end
