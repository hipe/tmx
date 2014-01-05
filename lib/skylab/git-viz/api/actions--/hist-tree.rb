module Skylab::GitViz

  class API::Actions__::Hist_Tree < API::Action_

    attribute :pathname, pathname: true, default: '.'

    def execute
      case @pathname.to_s
      when %r(/zang\z) ;  mock_not_found
      when %r(/core.rb\z) ; mock_is_file
      else mock_success ; end
    end
    def mock_not_found
      @VCS_listener.call :cannot_execute_command, :string do
        'No such file or directory - /foo/zang'
      end
      false
    end
    def mock_is_file
      @VCS_listener.call :cannot_execute_command, :string do
        'path is file, must have directory'
      end
      false
    end
    def mock_success
      GitViz::Models_::File_Node.get_mock_tree
    end
    def __execute_next__
      _VCS_front
      GitViz::Models_::File_Node[ :pathname, @pathname,
        :VCS_front, @VCS_front ]
    end
  end
end
