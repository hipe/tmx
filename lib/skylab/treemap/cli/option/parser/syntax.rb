module Skylab::Treemap
  class CLI::Option::Parser::Syntax < Bleeding::OptionSyntax
    include CLI::Option::Box::InstanceMethods

    def []= k, v                  # redefine any instance method you want!
      redefine_method! k, v       # (silly experimentation)
    end
                                  # called to create a new one from the
    def dupe                      # one that belongs to a class, for e.g.
      new = self.class.allocate
      other = self
      more_h = @more_h
      new.instance_exec do
        @switches = nil
        @more_h = { }
        more_h.each { |k, v| @more_h[k] = v.map { |x| x } }

        @on_definition_added_h = -> do
          h = other.on_definition_added_h # not autovivified, it's ok
          h ? h.dup : { }
        end.call
        self.definitions = ( d = other.definitions ) ? d.dup : d
      end
      new
    end

    def fetch_more k, &block      # a documentor will want to access these
      @more_h.fetch k, &block     # when it is in a documenting pass
    end
                                  # experimental hack to allow more
                                  # descs per option..
    def more name, block
      ( @more_h[ name ] ||= [] ) << block
      nil
    end

    def string emph=nil           # emphasize an option, **SUPREME HACK**
      if emph
        list = documentor.top.list.dup
        scn = CLI::Option::Box::Option_Scanner.new list
        pop = scn.fetch -> x { emph == x.normalized_name } # else fails
        list[ scn.count - 1, 1 ] = []
        @switches = list
        without = super()
        @switches = nil
        "#{ without } #{ hdr pop.rndr }"
      else
        super()
      end
    end

  protected

    def initialize( * )
      super
      @more_h = { }
    end

    def redefine_method! name, func # #todo `redefine_method` should not be so soft coded, predefine what methods can be so, or better yet add hooks
      if respond_to? name
        singleton_class.send :alias_method, "orig_#{ name }", name
      end
      singleton_class.send :define_method, name, &func
    end
  end
end
