require 'dossier'
require 'dossier/segmenter/engine'
require 'dossier/segmenter/version'

module Dossier
  class Segmenter
    attr_accessor :report

    class << self
      attr_accessor :report_class
    end

    def self.segments
      @segment_chain ||= Segment::Chain.new
    end

    def self.segment(name, options = {}, &block)
      segments << Segment::Definition.new(self, name, options)
      instance_eval(&block) if block_given?
    end

    def self.skip_headers
      segments.map(&:columns).flatten
    end

    delegate :skip_headers, to: "self.class"
    
    def initialize(report)
      self.report = report
      extend(segment_chain.first.segment_module) if report.segmented?
    end

    def headers
      @headers ||= report.results.headers.reject { |header| header.in?(skip_headers) }
    end

    def data
      @data ||= report.results.rows.inject(Hash.new { [] }) { |acc, row|
        acc.tap { |hash| hash[key_path_for(row)] += [row] }
      }
    end

    def segment_chain
      self.class.segments
    end

    def segmenter
      self
    end

    def segment_options_for(segment)
      # data.keys.reduce({}) do |acc, key| 
      #   acc.tap do |hash|
      #     k = key.split('.').first(segment.key_path.split('.').length + 1)
      #     hash[k] ||= data[key].first
      #   end
      # end.values

      # segmenter.data.keys.map{|k| k.split('.')}.inject({}) {|a,k| a[k.first(1)] ||= segmenter.data[k.join('.')].first; a}

      # segmenter.data.keys.map{|k| k.split('.')}.inject({}) {|a,k| a[k.first(3)] ||= segmenter.data[k.join('.')].first; a}.select { |k,v| k.first(2) == ['feline', 'false'] }.values

      # segment_position = 3

      position = segment.key_path.split('.').count
      data.keys.map { |key| 
        key.split('.') 
      }.inject({}) { |acc, key| 
        acc.tap { |hash| 
          hash[key.first(position + 1)] ||= data[key.join('.')].first
        }
      }.select { |key, value| 
        key.first(position) == segment.key_path.split('.')
      }.values.map { |row|
        Hash[report.results.headers.zip(row)]
      }
    end

    def key_path
      String.new
    end

    def inspect
      "#<#{self.class.name}>"
    end

    private

    def key_path_for(row)
      group_by_indexes.map { |i| row.at(i) }.join('.')
    end

    def segment_options
      data unless defined?(@data)
      @segment_options
    end

    def header_index_map
      @header_index_map ||= Hash[skip_headers.map { |h| [h, report.results.headers.index(h)] }]
    end

    def group_by_indexes
      @group_by_indexes ||= header_index_map.values_at(*segment_chain.map(&:group_by).map(&:to_s))
    end
  end
end

require "dossier/segment"
require "dossier/segment/chain"
require "dossier/segment/definition"
require "dossier/segment/rows"
require "dossier/segmenter/report"
