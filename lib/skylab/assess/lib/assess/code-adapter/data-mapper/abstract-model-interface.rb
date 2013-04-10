module Hipe
  module Assess
    module DataMapper

      #
      # The idea here is to wrap our orm-specific stuff with a common
      # interface that may one day be able to be used for other orms.
      #
      # It remains to be seen how fruitful this idea is.
      #
      # This should only be constructed with the orm manager.
      #
      # For now it does a ridiculously expensive hack to figure
      # out which module the modules exist in, when we don't know beforehand
      # what module it is.
      #
      class AbstractModelInterface
        include CommonInstanceMethods

        attr_reader :model
        # set by set! below:
        def initialize app_info
          @model_loaded = false
          @app_info = app_info
        end

        def model_loaded?
          @model_loaded
        end

        def main_model_name= name
          name = name.intern
          flail("expecting #{name} to be in data model. Had: "<<
            oxford_comma( model.keys)
          ) unless model.has_key?(name)
          def!(:main_model_name, name)
          main_model = model[name]
          def!(:main_model, main_model)
          nil
        end

        def join_model_for mixed_model1, mixed_model2
          model1 = deduce_model mixed_model1
          model2 = deduce_model mixed_model2
          hact = [model1.name_str, model2.name_str].sort.join('_').to_sym
          if model[hact]
            resp = model[hact]
          else
            fail("Can't deduce join model for #{model1} and #{model2}")
          end
          resp
        end

        def load_model_with_sexp_reflection
          mod = deduce_model_module
          load_and_enhance_model_classes_from_module mod
          @model_loaded = true
        end

        # see http://gist.github.com/344323 for loading multiple files
        def load_model
          fail("let's avoid reloading the model until we have to") if model_loaded?
          fail("can't handle multi-file models yet!") unless app.model.single_file?
          path = app.model.pretty_path_resolved
          fail("model not found: #{path}") unless File.exist?(path)
          require path
          @model_loaded = true
          nil
        end

      private

        def app; @app_info end

        def deduce_model mixed
          case mixed
          when ::DataMapper::Model
            resp = mixed
          when String
            resp = model[mixed.intern]
          when Symbol
            resp = model[mixed]
          else
            resp = nil
          end
          if resp.nil?
            fail("Can't deduce model from #{mixed.inspect}")
          end
          resp
        end

        #
        # expensive and silly fun (see previous more strict version
        # in 56c57).  The policy is only that each class of the data model
        # all exist under the same module (not the root namespace).  We don't
        # care if other non model classes and modules are defined in this
        # same module.
        #
        # We need to figure out what module the models are defined in,
        # without relying on configuration files to determine this.
        # (the model *is* the data.)
        #
        # So we need eventually to look at DataMapper::Module.descendants
        # and cross-reference it with the modules and classes defined here.
        #
        #
        #
        ColonColon = /::/
        def deduce_model_module
          file = pop_model_file_sexp
          them = file.module_tree.token_tree_flatten.
            map{|a|a.map(&:to_s)*'::'}
          these = ::DataMapper::Model.descendants.map(&:to_s)
          ridonk = these & them
          if ! ridonk.any?
            return flail("sorry, couldn't find any DataMapper Resources" <<
            "in #{app.model.pretty_path}")
          end
          if ridonk.map{|x| x.scan(ColonColon).size }.uniq.size != 1
            return flail("sorry, it appears that all model classess "<<
            "are not on the same level.")
          end
          toks = ridonk.first.split(ColonColon)
          toks.pop
          module_str = toks.join('::')
          string_to_constant(module_str)
        end

        def load_and_enhance_model_classes_from_module mod
          maybe_hack_association_classes
          @model = {}
          mod.constants.each do |const|
            cls = mod.const_get(const)
            if cls.ancestors.include?(::DataMapper::Resource)
              DmModelExtra[cls]
              @model[cls.name_sym] = cls
            end
          end
          nil
        end
        # note ::DataMapper::Model.descendants.to_ary would give a superset of

        def maybe_hack_association_classes
          unless DmAssociationExtra.hacked?
            DmAssociationExtra.hack!
          end
        end

        # know what you are doing if you remove deep_enhance! from here
        # know what you are doing if you use deep_enhance! anywhere else
        # this is akin to but more "advanced" then load_model
        def model_file_sexp
          @model_file_sexp ||= begin
            flail("no") unless app.model.single_file?
            flail("we need to implement this for multi-file models") unless
              app.model.single_file?
            file = CodeBuilder.get_file_sexp app.model.path
            if !(file.is_module? || file.is_block?)
              flail("not sure if this file has a structure we like.")
            end
            file.deep_enhance!
            file
          end
          file
        end

        # if u don't want to leave it hanging around in dumps, etc
        def pop_model_file_sexp
          res = model_file_sexp
          @model_file_sexp = nil
          res
        end

        # def model_class_sexps
        #   @underscores ||= begin
        #     underscores = {}
        #     classes = model_file_sexp.scope.block!.each_class do |node,|
        #       ModelClassSexp[node]
        #       # node.register!
        #       @underscores[node.class_name_underscored] = node
        #     end
        #     underscores
        #   end
        # end
      end
    end
  end
end
