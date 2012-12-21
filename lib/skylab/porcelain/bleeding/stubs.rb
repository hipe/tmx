module Skylab::Porcelain::Bleeding
  module Stubs
    def self.extended mod
      mod.send :extend, Stubs::ModuleMethods
    end
  end
  module Stubs::ModuleMethods
    def action_names
      @build_from_stub ||= ->(*a) { build_from_stub(*a) }
      ActionEnumerator.new do |y|
        Dir["#{dir}/*"].each do |path|
          y << Stubs::Stub.new( path.match(%r{((?:(?!\.rb)[^/])*)(?=(?:\.rb)?\z)})[0], # gulp
            @build_from_stub )
        end
      end
    end
    def action_helps
      ActionEnumerator.new do |y|
        action_names.each { |a| y << load_action(a) }
      end
    end
    def build_from_stub stub, *a
      load_action(stub).build(*a)
    end
    def load_action stub
      const_get stub.const
    end
  end
  class Stubs::Stub < Struct.new(:name, :build_proc)
    def build *a
      build_proc.call(self, *a)
    end
    def const
      name.gsub(/(?:^|-)([a-z])/){ $1.upcase }
    end
    def names
      [name]
    end
    def visible?
      true
    end
  end
end

