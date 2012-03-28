module Skylab::TanMan
  class Models::Remote::Collection < ::Enumerator
    Remote = Models::Remote
    attr_reader :resource
    def initialize resource
      block_given? and raise ArgumentError.new("this enumerator creates its own block.")
      @resource = resource
      super() do |y|
        resource.sections.each do |sec|
          if Remote::SECTION_NAME_RE =~ sec.section_name and rem = Remote.bound(self, sec)
            y << rem
          end
        end
      end
    end
    def push remote
      remote.bound? and fail("won't push bound remote")
      parent = resource.content_tree.detect(:sections)
      sexp = CodeMolester::Config::Section.create('', parent)
      remote.bind(sexp) ? self : false
    end
    OnRemove = PubSub::Emitter.new(:all, :error => :all, :info => :all, :write => :all)
    def remove remote, &on_info
      on_info.call(e = OnRemove.new)
      section_name = remote.sexp.section_name
      found = resource.sections.detect { |s| section_name == s.section_name }
      found or return e.error("expected section not found: [#{section_name}]")
      if resource.content_tree.detect(:sections).remove(found)
        e.emit(:write) { { resource: resource } }
        e.emit(:info, "removed remote #{remote.name}.")
        true
      end
    end
  end
end

