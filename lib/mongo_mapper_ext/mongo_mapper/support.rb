unless Class.method_defined? :alias
  Class.class_eval do
    def alias name = nil
      if name
        name.must_be.a String
        name.must_not_be.blank
        @alias = name.to_s
      else
        @alias ||= self.name.split('::').last
      end
    end
  end
end