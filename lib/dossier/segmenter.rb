require 'dossier'
require 'dossier/segmenter/engine'
require 'dossier/segmenter/version'

require "dossier/segmenter/summable"

module Dossier
  class Segmenter
    include Summable

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
      @headers ||= report_results.headers.reject { |header| header.in?(skip_headers) }
    end

    def data
      @data ||= report_results.rows.inject(Hash.new { [] }) { |acc, row|
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
        Hash[report_results.headers.zip(row)]
      }
    end

    def key_path
      String.new
    end

    def inspect
      "#<#{self.class.name}>"
    end
    
    def header_index_map
      @header_index_map ||= Hash[skip_headers.map { |h| [h, report_results.headers.index(h)] }]
    end

    private

    def report_results
      report.raw_results
    end

    def key_path_for(row)
      group_by_indexes.map { |i| row.at(i) }.join('.')
    end

    def segment_options
      data unless defined?(@data)
      @segment_options
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
require "dossier/segment/summary"
require "dossier/segmenter/report"
