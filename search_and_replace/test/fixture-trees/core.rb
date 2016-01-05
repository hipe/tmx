module Skylab::SearchAndReplace::TestSupport

  module Fixture_Trees

    class << self

      def [] entry_s

        ::File.join _dir_path, entry_s
      end

      define_method :_wat_FUNCTION_FILE_PATH, ( Callback_.memoize do
        self._K  # #todo-next
        _FUNCTIONS = 'functions'
        _DOTFILE = '.search-and-replace'

        ::File.join(
          Self__._wat_WORKSPACE_PATH,
          _DOTFILE,
          _FUNCTIONS,
          'stfu-omg.rb' )
      end )

      define_method :_wat_WORKSPACE_PATH, ( Callback_.memoize do
        self._K  # #todo-next
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
