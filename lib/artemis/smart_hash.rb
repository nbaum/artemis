module Artemis

  class SmartHash < Hash

    def self.key (*names)
      names.each do |name|
        define_method name do
          self[name]
        end
        define_method "#{name}=" do |value|
          self[name] = value
        end
      end
    end

  end

end
