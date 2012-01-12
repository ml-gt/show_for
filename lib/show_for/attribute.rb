module ShowFor
  module Attribute
    def attribute(attribute_name, options={}, &block)
      apply_default_options!(attribute_name, options)
      block = get_block_from_value_option(attribute_name, options) unless block
      collection_block, block = block, nil if collection_block?(block)
      
      value = if block
        block
      elsif @object.respond_to?(:"human_#{attribute_name}")
        @object.send :"human_#{attribute_name}"
      else
        @object.send(attribute_name)
      end

      wrap_label_and_content(attribute_name, value, options, &collection_block)
    end

    def value(attribute_name, options={}, &block)
      apply_default_options!(attribute_name, options)
      collection_block, block = block, nil if collection_block?(block)

      value = if block
        block
      elsif @object.respond_to?(:"human_#{attribute_name}")
        @object.send :"human_#{attribute_name}"
      else
        @object.send(attribute_name)
      end
      wrap_content(attribute_name, value, options, &collection_block)
    end

    def attributes(*attribute_names)
      attribute_names.map do |attribute_name|
        attribute(attribute_name)
      end.join.html_safe
    end
    
private

    def get_block_from_value_option(attribute_name, options)
      return unless options_value = options[:value]
      if options_value.is_a? Symbol
        if (@object.send(attribute_name).is_a?(Array) || @object.send(attribute_name).is_a?(Hash) )
          return lambda { |element| element.send(options_value) }
        else
          return lambda { @object.send(attribute_name).send(options_value) }
        end
      else
        if options_value.is_a? Proc
          return options_value
        else
          return lambda { options_value } 
        end
      end
    end

  end
end

