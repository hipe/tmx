module Skylab::MyTree
  class API::Actions::Nerk < API::Action

  protected

    def build_option_parser
    end

    def process
      emit :info, "sure"
    end
  end
end
