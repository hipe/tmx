module Skylab::TanMan
  class Models::Remote::Collection < ::Enumerator
    Remote = Models::Remote::Controller

    def clear_remote_collection
      # nothing to do - hold on to host, enumerator stays same. Careful!
    end

    attr_reader :resource

    def push remote
      remote.bound? and fail "won't push bound remote"
      sections = resource.sexp.child :sections
      sexp = sections.content_items.append_section ''
      if remote.bind sexp
        self
      else
        false
      end
    end

    on_remove = API::Emitter.new error: :all, info: :all, write: :all #[#046]

    define_method :remove do |remote, &on_info|
      result = nil
      begin
        e = on_remove.new on_info
        section_name = remote.sexp.section_name
        found = resource.sections.detect { |s| section_name == s.section_name }
        if ! found
          result = e.error "expected section not found: [#{ section_name }]"
          break
        end
        if resource.sexp.child( :sections ).remove found
          e.emit :write, resource: resource
          e.emit :info, "removed remote #{ remote.name }."
          result = true
        end
      end
      result
    end

  protected

    def initialize resource
      block_given? and raise ArgumentError.new(
        "this enumerator creates its own block." )
      @resource = resource
      super() do |y|
        self.resource.sections.each do |sec|
          if Remote::SECTION_NAME_RX =~ sec.section_name
            rem = Remote.bound self, sec
            if rem
              y << rem
            end
          end
        end
      end
    end
  end
end
