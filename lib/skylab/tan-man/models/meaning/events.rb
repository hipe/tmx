module Skylab::TanMan
  module Models::Meaning::Events
    # all here.
  end

  TanMan::Model::Event || nil # so it's prettier below

  class Models::Meaning::Events::Changed <
    Model::Event.new :name, :old_value, :new_value

    def build_message
      "changed meaning of #{ lbl name } from #{
      }#{ val old_value } to #{ val new_value }"
    end
  end

  class Models::Meaning::Events::Created <
    Model::Event.new :name, :is_before, :other_name, :bytes

    def build_message
      "added new meaning #{ lbl name } #{
      }#{ is_before ? 'before' : 'after' } #{
      }#{ lbl other_name } (#{ bytes } bytes)"
    end
  end

  class Models::Meaning::Events::Different_Value_Already_Set <
    Model::Event.new :name, :existing_value, :desired_value

    def build_message
      "there is already a meaning for #{ lbl name }"
    end
  end

  class Models::Meaning::Events::No_Starter <
    Model::Event.new :_ # meh

    def build_message
      "can't add meaning when none is there to start with!"
    end
  end

  class Models::Meaning::Events::Forgotten <
    Model::Event.new :name, :bytes

    def build_message
      "forgetting #{ lbl name } (#{ bytes } bytes)"
    end
  end

  class Models::Meaning::Events::Not_Found <
    Model::Event.new :name, :verb, :tense

    def build_message
      "#{ :present == tense ? 'found no existing' : 'there was no such' } #{
      }meaning to #{ verb }: #{ val name }"
    end
  end

  class Models::Meaning::Events::Same_Value_Already_Set <
    Model::Event.new :name

    def build_message
      "#{ lbl name } is already set to that value."
    end
  end
end
