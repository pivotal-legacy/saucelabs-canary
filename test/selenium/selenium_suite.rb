require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))
require 'test/unit/ui/console/testrunner'
require 'webrat'
require 'saucelabs_adapter'
require 'saucelabs_adapter/test_unit_adapter'

Webrat.configure do |config|
  config.mode = :selenium
end

require File.join(File.dirname(__FILE__), 'widget_test')