module Skylab::Brazen

  class Kernel_  # [#015]

    def initialize mod
      @module = mod
    end

    attr_reader :module

    def retrieve_unbound_action_via_normalized_name i_a
      i_a.reduce self do |m, i|
        scn = m.get_unbound_action_scan
        while cls = scn.gets
          _i = cls.name_function.as_lowercase_with_underscores_symbol
          i == _i and break( found = cls )
        end
        found or raise ::KeyError, "not found: #{ i } in #{ m }"
      end
    end

    def get_action_scan
      get_unbound_action_scan.map_by do |cls|
        cls.new self
      end
    end

    def get_unbound_action_scan
      get_model_scan.expand_by do |item|
        item.get_unbound_upper_action_scan
      end
    end

  private

    def get_model_scan
      mod = models_mod
      i_a = mod.constants
      i_a.sort!  # #note-35
      d = -1 ; last = i_a.length - 1
      Entity_[].scan do
        if d < last
          mod.const_get i_a.fetch( d += 1 ), false
        end
      end
    end

  public

    # ~ models & datastores

    def datastores
      @datastores ||= DataStores__.new self
    end

    def models
      @models ||= Models__.new self
    end

    def models_mod
      @module.const_get :Models_, false
    end

    class Things__

      def initialize mod, kernel, suffix
        @module = mod ; @kernel = kernel
        sc = singleton_class
        scn = mod.entry_tree.get_normpath_scanner  # go deep into [cb] API
        while np = scn.gets
          i = np.name_for_lookup.as_variegated_symbol
          sc.send :define_method, :"#{ i }#{ suffix }", bld_reader( i )
        end
        @cache_h = {}
      end

    private

      def bld_reader i
        -> &p do
          @cache_h.fetch i do
            cols = bld_shell( i ) and @cache_h[ i ] = cols
          end
        end
      end

      def bld_shell i
        Autoloader_.const_reduce( [ i ], @module ).build_collections @kernel
      end
    end

    class DataStores__ < Things__

      def initialize kernel
        super kernel.module.const_get( :Data_Stores_, false ), kernel, nil
      end
    end

    class Models__ < Things__

      def initialize kernel
        super kernel.models_mod, kernel, :s
      end
    end
  end
end
