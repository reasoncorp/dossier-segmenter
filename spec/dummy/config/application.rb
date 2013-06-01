ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler'

Bundler.setup

$:.unshift File.expand_path('../../../../lib', __FILE__)

require "action_controller/railtie"

Bundler.require

ApplicationController = Class.new(ActionController::Base)

require 'dossier/segmenter'

module Dummy
  class Application < ::Rails::Application
    config.cache_classes = true
    config.active_support.deprecation = :stderr
    config.secret_token = 'http://s3-ec.buzzfed.com/static/enhanced/webdr03/2013/5/25/8/anigif_enhanced-buzz-11857-1369483324-0.gif'
  end
end

Dummy::Application.initialize!

