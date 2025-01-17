require 'saucelabs_adapter/run_utils'

class Rake::Task
  def self.exists?(name)
    tasks.any? { |t| t.name == name }
  end
end

namespace :selenium do

  # Rake tasks are cumulative, and some old plugins are still defining selenium:server, so clear it.
  Rake::Task[:'selenium:server'].clear_actions if Rake::Task.exists?('selenium:server')

  desc "Run both test/unit and rspec tests, at saucelabs.com"
  task :ci  => [:'spec:sauce', :'suite'] do
    # TODO: Fix this, it ain't working.  Also update template rake file
    # saucelabs-adapter with any changes from here.
    if (File.exist?("sauce_connect.log") && ENV['CC_BUILD_ARTIFACTS'])
      FileUtils.cp("sauce_connect.log", ENV['CC_BUILD_ARTIFACTS'])
    end
  end
  
  desc "Run both test/unit and rspec tests, locally"
  task :localci  => [:local, :'spec:local']
  
  desc "Run the selenium remote-control server"
  task :server do
    system('selenium-rc')
  end

  desc "Run the selenium remote-control server in the background"
  task :server_bg do
    system('nohup selenium-rc 2>&1 &')
  end

  desc "Runs Selenium tests locally (selenium server must already be started)"
  task :local => [:local_env, :suite]

  desc "Run Selenium tests at saucelabs.com (using configuration 'saucelabs' in config/selenium.yml)"
  task :sauce => [:sauce_env, :suite]

  desc "Run Selenium tests using configuration SELENIUM_ENV (from config/selenium.yml)"
  task :custom => [:check_selenium_env_is_set, :suite]

  task :local_env do
    ENV['SELENIUM_ENV'] = 'local'
  end

  task :sauce_env do
    ENV['SELENIUM_ENV'] = 'saucelabs'
  end

  task :check_selenium_env_is_set do
    raise "SELENIUM_ENV must be set" unless ENV['SELENIUM_ENV']
  end

  task :suite do
    if (File.exists?("test/selenium/selenium_suite.rb"))
      RunUtils.run "ruby test/selenium/selenium_suite.rb"
    else
      puts "test/selenium/selenium_suite.rb not found, bailing.\nPlease create a script that will run your selenium tests."
      exit 1
    end
  end

  namespace :spec do
    desc "Runs Selenium tests locally (selenium server must already be started)"
    task :local => [:local_env, :suite]

    desc "Run Selenium tests at saucelabs.com (using configuration 'saucelabs' in config/selenium.yml)"
    task :sauce => [:sauce_env, :suite]

    task :suite do
      Rake::Task['spec:integration'].invoke
    end
  end
end
