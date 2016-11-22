module Skylab::Basic

  OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE = Home_::HookMesh.define :main do |defn|

    # this can serve as a logical template for cases when you need to deduce
    # charactersitics about a mixed value knowing nothing about it
    # beforehand. the subject instance is a partially complete "hook mesh"
    # that creates the skeleton of a deep if-else tree that contains only
    # "classification" and no "consequence". dup and modify this instance,
    # keeping in mind:
    #
    #   - all the entries in this file marked with hashtag-terminal
    #     will need to have hooks (procs) populated in the duped mesh.
    #
    #   - when duping the mesh you can in effect prune the subject mesh
    #     by replacing branch nodes with terminal nodes as appropriate
    #     to your use case (which may not need as much detail at that node).
    #
    #   - the opposite too - you could rewrite a "terminal" node
    #     to be a branch node as needed for your case.

    defn.main do |o|

      if o.value
        o.when( :trueish )[ o ]
      else
        o.when( :falseish )[ o ]
      end
    end

    defn.add :falseish do |o|

      if o.value.nil?
        o.when( :nil )[ o ]  # #terminal
      else
        o.when( :false )[ o ]  # #terminal
      end
    end

    defn.add :trueish do |o|

      x = o.value

      if x.respond_to? :ascii_only?
        o.when( :string )[ o ]

      elsif x.respond_to? :integer?
        o.when( :numeric )[ o ]

      elsif x.respond_to? :id2name
        o.when( :symbol )[ o ]  # #terminal

      elsif x == true
        o.when( :true )[ o ]  # #terminal

      else
        o.when( :other )[ o ]  # #terminal
      end
    end

    blank_rx = /\A[[:blank:]]*\z/
    defn.add :string do |o|

      if blank_rx =~ o.value
        o.when( :blank_string )[ o ]
      else
        o.when( :nonblank_string )[ o ]  # #terminal
      end
    end

    defn.add :blank_string do |o|

      if o.value.length.zero?
        o.when( :zero_length_string )[ o ]  # #terminal
      else
        o.when( :nonzero_length_blank_string )[ o ]  # #terminal
      end
    end

    defn.add :numeric do |o|

      x = o.value
      if x.zero?
        o.when( :zero )[ o ]  # #terminal
      elsif x.integer?
        o.when( :nonzero_integer )[ o ]
      else
        o.when( :nonzero_float )[ o ]
      end
    end

    defn.add :nonzero_integer do |o|

      if 0 < o.value
        o.when( :positive_nonzero_integer )[ o ]  # #terminal
      else
        o.when( :negative_nonzero_integer )[ o ]  # #terminal
      end
    end

    defn.add :nonzero_float do |o|

      if 0 < o.value
        o.when( :positive_nonzero_float )[ o ]  # #terminal
      else
        o.when( :negative_nonzero_float )[ o ]  # #terminal
      end
    end

    # ==
  end
end
# #history: born to DRY [ba] string "via mixed" and [tab] statistics.
