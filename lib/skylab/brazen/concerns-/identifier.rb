module Skylab::Brazen

  class Concerns_::Identifier  # :[#022].

    class << self

      def via_name_function nf, x
        new do
          @is_resolved = true
          @_implementor = Name_Function_as_Implementor___.new nf, x
        end
      end

      def via_symbol sym
        new do
          @is_resolved = false
          @_implementor = Resolving_Implementor__.new sym
        end
      end

      def via_string_and_frozen_silo_name_parts s, i_a
        new do
          @is_resolved = false
          @_implementor = Literal_Implementor___.new s, i_a
        end
      end
    end  # >>

    attr_reader :is_resolved

    def initialize & edit_p
      instance_exec( & edit_p )
    end

    def members
      [ :description, :entity_name_string, :full_name_symbol,
        :name_parts, :raw_name_parts,
        :silo_description, :silo_name_symbol, :silo_name_parts,
        :silo_slug, :value ]
    end

    def description
      _s = silo_description
      _s_ = entity_name_string
      [ _s, _s_ ].compact.join SPACE_
    end

    def silo_description
      silo_name_parts.map do |i|
        i.id2name.gsub( UNDERSCORE_, DASH_ )
      end.join SPACE_
    end

    def full_name_symbol
      @_implementor.full_name_symbol
    end

    def silo_name_symbol
      @_implementor.silo_name_symbol
    end

    def silo_slug
      @_implementor.silo_slug
    end

    def entity_name_string  # where available
      @_implementor.entity_name_string
    end

    def raw_name_parts
      @_implementor.raw_name_parts
    end

    def name_parts
      @_implementor.name_parts
    end

    def silo_name_parts
      @_implementor.silo_name_parts
    end

    def value
      @_implementor.value
    end

    def with_local_entity_identifier_string s
      i_a = name_parts
      if i_a
        if entity_name_string
          i_a = i_a[ 0 .. -2 ].freeze
        end
        self.class.via_string_and_frozen_silo_name_parts s, i_a
      end
    end

    def as_mutable_for_resolving
      @_implementor = @_implementor.as_mutable_for_resolving
      self
    end

    def add_demarcation_index d
      @_implementor.add_demarcation_index d
    end

    def bake x
      @is_resolved = true
      @_implementor = @_implementor.bake x ; nil
    end

    class Common_Implementor__

      attr_reader :full_name_symbol, :name_parts, :silo_name_symbol, :value

      def silo_slug
        @ss ||= ( i = silo_name_symbol and i.to_s.gsub( UNDERSCORE_, DASH_ ).freeze )
      end
    end

    class Name_Function_as_Implementor___ < Common_Implementor__

      def initialize nf, value
        np_a = []
        while true
          np_a.push nf.as_variegated_symbol
          par = nf.parent
          par or break
          nf = par.name_function
        end
        np_a.reverse!
        @name_parts = np_a.freeze
        @silo_name_symbol = ( @name_parts * UNDERSCORE_ ).intern
        @full_name_symbol = @silo_name_symbol
        @value = value
      end

      def entity_name_string
      end

      def silo_name_parts
        @name_parts
      end
    end

    class Literal_Implementor___ < Common_Implementor__

      def initialize s, i_a
        @entity_name_string = s.dup.freeze
        @i_a = i_a
      end

      attr_reader :entity_name_string

      def name_parts
        @np ||= @i_a.dup.push( @entity_name_string ).freeze
      end

      def silo_name_symbol
        @sni ||= @i_a.join( UNDERSCORE_ ).intern
      end

      def silo_name_parts
        @i_a
      end

      def full_name_symbol
        @fni ||= name_parts.join( UNDERSCORE_ ).intern
      end

      def as_mutable_for_resolving  # #watching [#036]
        Resolving_Implementor__.new @i_a.join( UNDERSCORE_ ).intern, @entity_name_string
      end
    end

    class Resolving_Implementor__ < Common_Implementor__

      def initialize i, s=nil
        @silo_name_symbol = nil
        @entity_name_string = s
        @full_name_symbol = i
      end

      attr_reader :entity_name_string

      def raw_name_parts
        @rnp ||= @full_name_symbol.id2name.split UNDERSCORE_
      end

      def as_mutable_for_resolving
        self
      end

      def add_demarcation_index d
        ( @d_a ||= [] ).push d ; nil
      end

      def silo_name_symbol
        if @silo_name_symbol
          @silo_name_symbol
        else
          @full_name_symbol
        end
      end

      def silo_name_parts
        @name_parts
      end

      def bake x
        begin_d = 0
        @d_a.freeze
        @name_parts = @d_a.map do | begin_next_d |
          i = ( @rnp[ begin_d ... begin_next_d ] * UNDERSCORE_ ).intern
          begin_d = begin_next_d
          i
        end.freeze
        if @rnp.length > begin_d
          @entity_name_string and self._SANITY
          @entity_name_string = ( @rnp[ begin_d .. -1 ] * UNDERSCORE_ )
        end
        @silo_name_symbol = ( @name_parts * UNDERSCORE_ ).intern
        @value = x
        self
      end
    end
  end
end
