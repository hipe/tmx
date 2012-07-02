module Skylab::TanMan
  module API::Actions::Remote
  end
  class API::Actions::Remote::List < API::Action
    attribute :verbose, :boolean => true, :default => false
    def execute
      if ! config.ready?
        return
      end
      tbl = Enumerator.new do |y|
        rr = config.remotes
        rr.each do |r|
          y << Enumerator.new do |yy|
            yy << r.name
            yy << r.url
            if verbose?
              yy << [:resource_label, r.resource_label]
            end
          end
        end
      end
      seen = config.remotes.num_resources_seen
      tbl.singleton_class.send(:define_method, :num_resources_seen) { seen }
      tbl
    end
  end
end

