#!/usr/bin/env ruby -wKU

module StupidRecord
  module Attributes
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      @attributes = []

      def attributes
        @attributes
      end

      def attribute(name)
        getter = :"#{name}"
        setter = :"#{name}="
        variable = :"@#{name}"

        @attributes ||= []
        @attributes << getter unless @attributes.include? getter

        define_method getter do
          instance_variable_get variable
        end

        define_method setter do |value|
          instance_variable_set variable, value
        end
      end
    end
  end
end