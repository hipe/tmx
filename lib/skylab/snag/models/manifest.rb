module Skylab::Snag

  module Models::Manifest

    require_relative 'manifest/file'     # [#mh-035] preload bc toplevel exists

    header_width = '[#867] '.length

    line_width = 80

    define_singleton_method :header_width do header_width end

    define_singleton_method :line_width do line_width end
  end
end
