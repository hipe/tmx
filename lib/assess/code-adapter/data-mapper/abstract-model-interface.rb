module Hipe
  module Assess
    module DataMapper

      #
      # The idea here is to wrap our orm-specific stuff with a common
      # interface that may one day be able to be used for other orms.
      #
      # This should only be constructed with the orm manager.
      #
      # For now all it does is a ridiculously expensive hack to figure
      # out which module the modules exist in, when we don't know beforehand
      # what module it is.
      #
      class AbstractModelInterface
        include CommonInstanceMethods

        attr_reader :model
        # set by set! below:
        def initialize app_info
          @app_info = app_info
          mod = deduce_model_module
          load_and_enhance_model_classes_from_module mod
        end

        def main_model_name= name
          name = name.intern
          flail("expecting #{name} to be in data model. Had: "<<
            oxford_comma(@model.keys)
          ) unless @model.has_key?(name)
          def!(:main_model_name, name)
          main_model = @model[name]
          def!(:main_model, main_model)
          nil
        end

      private

        attr_reader :app_info

        #
        # expensive and silly but fun
        #
        def deduce_model_module
          file = model_file_sexp
          @model_file_sexp = nil # don't want it in dumps
          target = s(:call,nil,:include,
            s(:arglist, s(:colon2, s(:const, :DataMapper), :Resource))
          )
          found = file.deep_find_first target
          if ! found
            CodeBuilder::CommonSexpInstanceMethods[target]
            fail("failed to find #{target.to_ruby} in "<<
              app_info.model.path
            )
          end
          mod = found.find_parent(:module)
          if (found2 = mod.find_parent(:module))
            debugger; 'no problem but we need to deal with it.'
          end
          module_name_string = mod.module_name_symbol.to_s
          mod = CodeBuilder.const_get_deep(module_name_string)
          mod
        end

        def load_and_enhance_model_classes_from_module mod
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

        def model_file_sexp
          @model_file_sexp ||= begin
            flail("no") unless app_info.model.single_file?
            file = CodeBuilder.build_file app_info.model.path
            if !(file.is_module? || file.is_block?)
              flail("not sure if this file has a structure we like.")
            end
            file.deep_enhance!
            file
          end
          file
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
