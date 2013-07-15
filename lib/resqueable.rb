module Resqueable
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.testit(base)
  end

  module InstanceMethods

  end

  module ClassMethods
    class << self
      def make_(clazz)
        clazz.class_eval do
          define_method "perform" do
            123
          end
        end
      end
    end
  end
end