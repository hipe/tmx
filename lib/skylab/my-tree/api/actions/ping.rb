module Skylab::MyTree

  class API::Actions::Ping < API::Action

    desc "this is ping, only one line of description."

  private

    def build_option_parser
    end

    def process
      emit :info, "hello from my-tree."
      :'hello_from_my-tree'
    end
  end
end
