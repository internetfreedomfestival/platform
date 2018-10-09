# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :horizontal do |b|
    b.use :html5
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
    end
  end

  config.wrappers :horizontal_string, tag: 'div', class: 'clearfix stringish', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label
    b.use :error, wrap_with: { tag: :span, class: :error }

    # TODO * not shown on password field
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :default, tag: 'div', class: 'clearfix form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.wrapper tag: 'div', class: 'form-label' do |ba|
      ba.use :label
      ba.use :error, wrap_with: { tag: :span, class: 'form-input__error' }
    end

    b.wrapper tag: 'div', class: 'form-help' do |ba|
      ba.use :hint, wrap_with: { tag: :span, class: 'form-help__text' }
    end

    b.wrapper tag: 'div', class: 'form-input' do |ba|
      ba.use :input
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'clearfix', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label

    # TODO right align, margin, missing ul<li
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :check_boxes, tag: 'div', class: 'inputs-list clearfix', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label
    b.use :error, wrap_with: { tag: :span, class: :error }

    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input, wrap_with: { tag: :div, class: 'clearfix' }
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.default_wrapper = :default

  # http://simple-form.plataformatec.com.br/#available-input-types-and-defaults-for-each-column-type
  config.wrapper_mappings = {
    inline_boolean: :horizontal_boolean,
    #email: :horizontal_string,
    rating: :horizontal,
    check_boxes: :check_boxes,
    hidden: :horizontal
  }
end
