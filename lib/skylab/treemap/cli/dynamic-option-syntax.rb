module Skylab::Treemap
  class CLI::DynamicOptionSyntax < Skylab::Porcelain::Bleeding::OptionSyntax
    include CLI::OptionSyntaxReflection
    include Skylab::Treemap::MetaHell

    def dupe
      self.class.new.dupe!(self)
    end
    def dupe! other
      @more = other.more.dup
      @on_definition_added = (h = other.instance_variable_get('@on_definition_added') and h.dup) or {}
      self.definitions.concat other.definitions
      self
    end
    def more
      @more ||= {}
    end
    alias_method :[]=, :redefine_method!
  end
end

