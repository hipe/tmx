module Skylab::Slicer

  class API::Actions::Transfer < Slicer_._lib.API_action

    params :dry_run

    listeners_digraph  :info_line, :info_message

    def execute
      info_line 'sure.'
      info_message "okay."
      nil
    end
  end
end
