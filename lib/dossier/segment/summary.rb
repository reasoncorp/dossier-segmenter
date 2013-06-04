module Dossier
  class Segment
    class Summary

      attr_reader :count, :average, :sum

      def initialize(headers)
        @headers = headers.map(&:to_s)
        @count   = 0
        @sums    = headers.map { 0 }
      end

      def <<(row)
        @count += 1
        row.each_with_index { |v, i| sums[i] += parse(v) }
        self
      end

      def sum(key)
        sums.at(index_of key)
      end

      def average(key)
        sum(key) / count
      end

      private

      attr_reader :headers, :sums

      def index_of(key)
        indexes[key.to_s] ||= headers.index(key.to_s) or raise_missing_header(key)
      end

      def indexes
        @indexes ||= {}
      end

      def parse(value)
        BigDecimal.new(value.to_s)
      end

      def raise_missing_header(key)
        raise HeaderError.new %Q[No such header '#{key}' in headers: #{headers.join(', ')}]
      end

      HeaderError = Class.new(StandardError)
    end
  end
end
