module Skylab::TanMan

  class API::Actions::Remote::List < API::Action
    extend API::Action::Attribute_Adapter

    attribute :verbose, :boolean => true, :default => false

  protected

    def execute
      result = nil
      begin
        config.ready? or break
        tbl = ::Enumerator.new do |y|
          rr = config.remotes
          rr.each do |r|
            y << ::Enumerator.new do |yy|
              yy << r.name
              yy << r.url
              if verbose?
                yy << [:resource_label, r.resource_label]
              end
            end
          end
        end
        seen = config.remotes.num_resources_seen
        tbl.singleton_class.send(:define_method, :num_resources_seen) { seen } # WAT
        result = tbl
      end while nil
      result
    end
  end
end
