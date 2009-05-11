class Hash
  # Convert all keys from string to symbols and return converted hash.
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

  # Convert all keys from string to symbols in place.
  def symbolize_keys!
    self.replace self.symbolize_keys
  end

  def deep_symbolize_keys(hash = self)
    hash.inject({}) do |result, (key, value)|
      value = deep_symbolize_keys(value) if value.is_a? Hash
      result[(key.to_sym rescue key) || key] = value
      result
    end
  end

  def assert_required_keys(*required_keys)
    missing_keys = [required_keys].flatten - keys
    raise(ArgumentError, "missing key(s): #{missing_keys.join(", ")}") unless missing_keys.empty?
  end

  # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
  # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbols
  # as keys, this will fail.
  #
  # ==== Examples
  #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): name, age"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end

  def has_keys?(*required_keys)
    missing_keys = [required_keys].flatten - keys
    missing_keys.empty?
  end
end