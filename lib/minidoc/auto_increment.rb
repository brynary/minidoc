class Minidoc
  module AutoIncrement
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def auto_increment(field, options = {})
        start = options.fetch(:start, 0)
        step_size = options.fetch(:step_size, 1)

        attribute field, Integer, default: start

        class_eval(<<-EOM)
          def next_#{field}
            Minidoc::AutoIncrement::Incrementor.
              new(self, :#{field}).next_value(#{step_size})
          end
        EOM
      end
    end

    class Incrementor
      def initialize(record, field)
        @record = record
        @field = field
      end

      def next_value(step_size = 1)
        result = record.class.collection.find_and_modify(
          query: { _id: record.id },
          update: { "$inc" => { field => step_size } },
          new: true,
        )

        result[field.to_s]
      end

      private

      attr_reader :record, :field
    end
  end
end
