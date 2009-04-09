module SearchableRecord
  module Meta #:nodoc:
    module VERSION
      MAJOR = 0
      MINOR = 0
      BUILD = 5

      def self.to_s
        [ MAJOR, MINOR, BUILD ].join(".")
      end
    end
  end
end
