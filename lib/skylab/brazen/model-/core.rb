module Skylab::Brazen

  class Model_  # read [#013]

    class << self

      attr_accessor :custom_inflection, :description_block

    end

    Actor = Lib_::Snag__[]::Model_::Actor

    include module Interface_Element_Instance_Methdods__

      def name
        self.class.name_function
      end

      def has_description
        ! self.class.description_block.nil?
      end

      def under_expression_agent_get_N_desc_lines expression_agent, d=nil
        Brazen_::Lib_::N_lines[].
          new( [], d, [ self.class.description_block ], expression_agent ).
           execute
      end

      self
    end

    def is_branch
      true
    end

    def is_visible
      true
    end

    # ~ action scanning

    class << self
      def get_upper_action_scan
        acr = actn_class_reflection
        acr and acr.get_upper_action_class_scanner.map_by do |cls|
          cls.new
        end
      end
      def actn_class_reflection
        @did_reslolve_acr ||= init_action_class_reflection
        @acr
      end
    private
      def init_action_class_reflection
        @acr = Build_any_action_class_reflection__[ self ]
        true
      end
    end

    def get_lower_action_scan
      acr = self.class.actn_class_reflection
      acr and acr.get_lower_action_class_scanner.map_by do |cls|
        cls.new
      end
    end

    class Build_any_action_class_reflection__

      Actor[ self, :properties, :cls ]

      def execute
        has = @cls.const_defined? ACTIONS__, false  # #one
        has ||= @cls.entry_tree.instance_variable_get( :@h ).key? ACTIONS___
        has and work
      end
      ACTIONS__ = :Actions ; ACTIONS___ = 'actions'.freeze

      def work
        Progressive_Action_Class_Reflection__.
          new @cls, @cls.const_get( ACTIONS__, false )
      end
    end

    class Progressive_Action_Class_Reflection__
      def initialize * a
        @cls, @mod = a
      end
      def get_upper_action_class_scanner
        @did_partion ||= prttn
        Entity_[].scan_nonsparse_array @promoted_action_class_a
      end
      def get_lower_action_class_scanner
        @did_partion ||= prttn
        Entity_[].scan_nonsparse_array @non_promoted_action_class_a
      end
    private
      def prttn
        @promoted_action_class_a, @non_promoted_action_class_a =
          action_class_a.partition do |cls|
            cls.is_promoted
          end
        @non_promoted_action_class_a.length.nonzero? and
          @promoted_action_class_a.push @cls  # #two
        DONE_
      end
      def action_class_a
        @action_class_a ||= mod_constants.map { |i| @mod.const_get i, false }.freeze
      end
      def mod_constants
        @mod_constants ||= @mod.constants.freeze
      end
    end

    class Action_as_Item__

      def initialize bound
        @bound = bound
        @cls = bound.class
      end

      def name
        @bound.name
      end

      def has_description
        @cls.description_block
      end

      def under_expression_agent_get_N_desc_lines exp, n=nil
        Brazen_::Lib_::N_lines[].
          new( [], n, [ @cls.description_block ], exp ).execute
      end
    end

    Entity_ = -> { Brazen_::Entity }
  end
end
