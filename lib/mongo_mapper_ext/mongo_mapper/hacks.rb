ActiveModel::Name.class_eval do
  def initialize klass, name = nil
    name ||= klass.name
    
    super name
    
    @klass = klass
    @singular = ActiveSupport::Inflector.underscore(self).tr('/', '_').freeze
    @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
    @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).freeze
    @human = ActiveSupport::Inflector.humanize(@element).freeze
    @collection = ActiveSupport::Inflector.tableize(self).freeze
    @partial_path = "#{@collection}/#{@element}".freeze
    @i18n_key = ActiveSupport::Inflector.underscore(self).tr('/', '.').to_sym
  end
end
