require 'spec_helper'
require 'capybara/rspec'
require 'database_cleaner/active_record'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# supportディレクトリ以下を読み込む
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.include FactoryBot::Syntax::Methods

  # JS テストではトランザクションが効かないため false にする
  config.use_transactional_fixtures = false

  config.filter_rails_from_backtrace!
  config.include Warden::Test::Helpers
  config.after(:each) { Warden.test_reset! }

  # Capybara 設定（共通）
  Capybara.default_max_wait_time = 5
  Capybara.ignore_hidden_elements = true
  Capybara.match = :prefer_exact

  # system spec のドライバ切替（example の metadata[:js] を利用）
  config.before(:each, type: :system) do |example|
    if example.metadata[:js]
      if ENV['SHOW_BROWSER'] == 'true'
        driven_by(:selenium_chrome) # 非ヘッドレスでブラウザを表示
      else
        driven_by(:selenium_chrome_headless)
      end
    else
      driven_by(:rack_test)
    end
  end

  config.after(:each, type: :system) do |example|
    if example.exception && Capybara.current_driver != :rack_test
      save_screenshot("tmp/capybara/#{example.full_description.parameterize}.png")
      save_page("tmp/capybara/#{example.full_description.parameterize}.html")
    end
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
