# frozen_string_literal: true

require "test_helper"
require "rake"

class TestStellwerkRakeTask < Minitest::Test
  def setup
    Rake::Task.clear
    load File.expand_path("../../lib/tasks/stellwerk.rake", __dir__)
  end

  def teardown
    Rake::Task.clear
  end

  def test_check_simple_invokes_check_with_current_directory_and_runs
    check_instance = mock("check")
    check_instance.expects(:run).once

    Stellwerk::Commands::Check.expects(:new).with(Dir.pwd).returns(check_instance)

    Rake::Task["stellwerk:check_simple"].invoke
  end

  def test_check_invokes_check_with_rails_root_and_autoloaders
    Rake::Task.define_task(:environment)

    main_loader = Object.new
    fake_autoloaders = Struct.new(:main, :once).new(main_loader, nil)
    fake_root = Pathname.new("/tmp/app")
    check_instance = mock("check")
    check_instance.expects(:run).once

    Rails.stubs(:autoloaders).returns(fake_autoloaders)
    Rails.stubs(:root).returns(fake_root)
    Stellwerk::Commands::Check.expects(:new)
      .with(fake_root, autoloaders: [main_loader])
      .returns(check_instance)

    Rake::Task["stellwerk:check"].invoke
  end
end
