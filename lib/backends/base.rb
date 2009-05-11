def backend_module
  define_method(:present?) do
    true
  end

  define_method(:name) do
    self.class.to_s
  end
end
