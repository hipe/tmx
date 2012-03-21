module Skylab::TanMan
  module Api::Actions::Remote
  end
  class Api::Actions::Remote::List < Api::Action
    def execute
      config? or return
      Enumerator.new do |y|
        config.remotes.each do |r|
          y << Enumerator.new do |yy|
            yy << r.name
            yy << r.url
          end
        end
      end
    end
  end
end

