require 'skylab/code-molester/config/file'
Skylab::TanMan::CodeMolester = Skylab::CodeMolester # in one place


module Skylab::TanMan
  require ROOT.join('models/model')
  require ROOT.join('models/remote')

  class Models::Config
    extend Bleeding::DelegatesTo
    def add_remote name, host
      r = Models::Remote.unbound(self, name, host) or return false
      name = r.name # normalization maybe
      if r2 = remotes.detect { |rr| name == rr.name }
        emit(:info, "remote #{name.inspect} already exists.")
        true
      else
        remotes.push r
        write_hook
      end
    end
    attr_reader :bridge
    delegates_to :runtime, :emit
    def error m ; emit(:error, m) ; false end
    def initialize runtime, path_proc
      @runtime = runtime
      @bridge = CodeMolester::Config::File.new(:path => path_proc.call)
    end
    def init
      stdout = runtime.stdout # sucky
      bridge.on_write do |o|
        o.on_error { |e| emit(:error, *e.payload) ; return false }
        o.on_before_edit { |e| stdout.write(e) }
        o.on_before_create { |e| stdout.write(e) }
        b = ->(e){ stdout.puts(" .. done (#{e.tap(&:touch!).payload[1]} bytes.)") }
        o.on_after_edit(&b)
        o.on_after_create(&b)
        o.on_all { |e| e.touched or emit(:info, *e.payload) }
      end
      bridge.on_read do |o|
        o.on_all { |e| emit(:info, *e.payload) }
      end
      if bridge.exist?
        bridge.read or return false
      else
        load_default_content
        bridge.write or return false
      end
      self
    end
    def load_default_content
      bridge.content_tree.tap do |o|
        o.prepend_comment '' # in reverse
        o.prepend_comment "parts of this file may have been generated and may be overwritten"
        o.prepend_comment "created #{Time.now.localtime} by tanman"
      end
    end
    def remotes
      Models::Remote::MyEnumerator.new(self)
    end
    attr_reader :runtime
    def write_hook
      if bridge.exist? && bridge.pathname_read == bridge.content
        emit :info, "(config file didn't change.)"
        return true
      end
      bridge.write
    end
  end
end

