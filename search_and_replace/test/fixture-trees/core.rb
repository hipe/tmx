module Skylab::BeautySalon::TestSupport

  module Models::Search_And_Replace::Fixture_Trees

    class << self

      def [] entry_s

        ::File.join _dir_path, entry_s
      end

      define_method :STFU_OMG_FUNCTION_FILE_PATH, ( Callback_.memoize do

        _FUNCTIONS = 'functions'
        _DOTFILE = '.search-and-replace'

        ::File.join(
          Self__.STFU_OMG_WORKSPACE_PATH,
          _DOTFILE,
          _FUNCTIONS,
          'stfu-omg.rb' )
      end )

      define_method :STFU_OMG_WORKSPACE_PATH, ( Callback_.memoize do

        ::File.join(
          Self__.dir_pathname.to_path,
          '00-has-hidden-workspace-with-stfu-omg-function' )
      end )


      def _dir_path
        @___ ||= dir_pathname.to_path
      end

    end  # >>

    Self__ = self
  end
end
