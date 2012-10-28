require 'skylab/treetop-tools/core'
require 'skylab/face/core'

module Skylab::TanMan
  module Parser end
  module Parser::InstanceMethods
    include ::Skylab::Face::PathTools::Constants # ABSOLUTE_PATH_HACK_RX
    include ::Skylab::Face::PathTools::InstanceMethods
    include ::Skylab::TreetopTools::Parser::InstanceMethods

    attr_accessor :on_load_parser_info_f # used usu. in tests to customize UI

    def pretty_path_hack msg
      msg.gsub(ABSOLUTE_PATH_HACK_RX) { |s| pretty_path s }
    end
  end
end
