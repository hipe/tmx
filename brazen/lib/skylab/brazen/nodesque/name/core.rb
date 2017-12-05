module Skylab::Brazen

  Nodesque::Name = ::Class.new ::Class.new Common_::Const_Name

  class Nodesque::Name

    # notes in [#005] - this is almost an abstract base. see #here

    class << self

      def name_with_parent_class
        Name_with_Parent__
      end
    end  # >>

    Build_full_name_function = -> mod do

      nf = mod.name_function
      y = [ nf ]
      begin
        parent = nf.parent
        parent or break
        nf = parent.name_function
        nf or break
        y.unshift nf
        redo
      end while nil
      y.freeze
    end

    module Build_name_function  # see [#here.A]

      _NFM = -> do
        @name_function ||= Build_name_function[ self ]  # :+#public-API (ivar name)
      end

      split = -> s do
        d = s.rindex CONST_SEP_
        [ s[ 0, d ], s[ ( d + 2 ) .. -1 ] ]
      end

      cache = {}

      cached_dereference = -> s do

        cache.fetch s do

          cache[ s ] = s.split( CONST_SEP_ ).reduce ::Object do | m, c |
            m.const_get c, false
          end
        end
      end

      entry_for = nil
      norm_rx = /\AActions_*\z/
      top_rx = /::Models_\z/

      build_entry = -> str do

        x_s, base_s = split[ str ]
        sym = base_s.intern

        if top_rx =~ x_s

          _parent_parent = cached_dereference[ x_s ]

          me = _parent_parent.const_get sym, false
        else

          x_s_, box_base_s = split[ x_s ]

          if norm_rx =~ box_base_s

            ent = entry_for[ x_s_ ]
            parent = ent.x

            if ! parent.respond_to? :name_function
              parent.send :define_singleton_method, :name_function, _NFM
            end

            _box_module = parent.const_get box_base_s, false

            me = _box_module.const_get sym, false
          else

            # for nonstandard trees (transplanting nodes ([br] only?))

            parent = cached_dereference[ x_s ]

            me = parent.const_get sym, false

          end
        end

        Entry___.new me, sym, parent
      end

      entry_for = -> s do
        cache.fetch s do
          cache[ s ] = build_entry[ s ]
        end
      end

      define_singleton_method :[] do | unb |

        entry = entry_for[ unb.name ]

        _cls = if unb.respond_to? :name_function_class
          unb.name_function_class
        else
          Here_
        end

        _cls.new_via unb, entry.parent_module, entry.intern
      end
    end

    Entry___ = ::Struct.new :x, :intern, :parent_module

    # ~ as class

    def _init_via_three cls, parent, const_i

      @class_ = cls
      super
    end

    attr_reader :class_

    def inflected_noun
      _inflection.inflected_noun
    end

    def noun_lexeme
      _inflection.noun_lexeme
    end

    def _inflection

      # #here is the only method that would be in the would-be dedicated
      # subclass for model names.

      @___inflection ||= Here_::Common_Inflectors::Inflector_for_Model.new self
    end

    Name_with_Parent__ = superclass
    class Name_with_Parent__

      class << self

        def new_via mod, parent, const_sym

          new._init_via_three mod, parent, const_sym
        end

        private :new
      end  # >>

      def _init_via_three _mod, parent, const_sym

        @parent = parent
        finish_via_normal_symbol const_sym
      end

      attr_reader :parent
    end

    Here_ = self
  end
end
