module Skylab::MyTree
  class API::Actions::Nerk < API::Action

    desc "this is nerk, only one line of description."

  protected

    def build_option_parser
    end

    def process
      emit :info, "sure"
    end
  end
end
