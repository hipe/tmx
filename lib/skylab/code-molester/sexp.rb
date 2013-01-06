module ::Skylab::CodeMolester
  # thanks to zenspider


  class Sexp < ::Array

    # this name for this method is experimental.  the name may change.
    def detect *a, &b
      (b or 1 != a.size or !(::Symbol === a.first)) and return super
      self[1..-1].detect { |n| ::Array === n and n.first == a.first }
    end

    def last *a
      0 == a.size and return super
      ii = (size-1).downto(1).detect { |i| ::Array === self[i] and self[i].first == a.first }
      self[ii] if ii
    end

    def remove sexp
      size <= 1 and return fail "cannot remove anything from empty sexp!"
      oid = sexp.object_id
      index = (1..(size-1)).detect { |idx| oid == self[idx].object_id }
      index or return fail "sexp with oid #{oid} was not an immediate child of this sexp."
      self[index, 1] = [] # ruby is amazing
      sexp
    end

    def select *a, &b
      (b or 1 != a.size or !(::Symbol === a.first)) and return super
      self[1..-1].select { |n| ::Array === n and n.first == a.first }
    end

    def symbol_name
      ::Symbol === first ? first : false
    end

    def unparse sio=nil
      out = sio || CodeMolester::Services::StringIO.new
      self[1..-1].each do |child|
        if child.respond_to? :unparse
          child.unparse out
        else
          out.write child.to_s
        end
      end
      out.string unless sio
    end
  end


  class << Sexp

                                  # builds the sexp either with the registered
    def [] *a                     # factory or as a generic sexp based on if
      k = if factory_ivar and a.length.nonzero?  # a factory with that name was
        @factory[a.first]         # registered. uses self as a default here
      else                        # (see below)
        self
      end
      k.new.concat a
    end

    def []= symbol_name, sexp_klass            # register a factory
      factory[symbol_name] = sexp_klass
    end

    attr_reader :factory ; alias_method :factory_ivar, :factory

    def factory
      @factory ||= ::Hash.new self
    end
  end
end
