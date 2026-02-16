# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class TestSourceFileCollector < Minitest::Test
  def test_call_filters_out_excluded_directories
    Dir.mktmpdir do |dir|
      allowed_ruby_file = File.join(dir, "app/models/user.rb")
      allowed_erb_file = File.join(dir, "app/views/users/show.html.erb")
      excluded_db_file = File.join(dir, "db/schema.rb")
      excluded_vendor_file = File.join(dir, "vendor/gems/foo.html.erb")

      [allowed_ruby_file, allowed_erb_file, excluded_db_file, excluded_vendor_file].each do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "# test\n")
      end

      collector = Stellwerk::SourceFileCollector.new(dir, exclude_paths: ["db/", "vendor/"])

      files = collector.call.map(&:to_s)

      assert_includes files, allowed_ruby_file
      assert_includes files, allowed_erb_file
      refute_includes files, excluded_db_file
      refute_includes files, excluded_vendor_file
    end
  end

  def test_call_uses_directory_boundaries_for_excludes
    Dir.mktmpdir do |dir|
      included_file = File.join(dir, "app/models/vendor_record.rb")
      excluded_file = File.join(dir, "vendor/models/vendor_record.rb")

      [included_file, excluded_file].each do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "# test\n")
      end

      collector = Stellwerk::SourceFileCollector.new(dir, exclude_paths: ["vendor/"])

      files = collector.call.map(&:to_s)

      assert_includes files, included_file
      refute_includes files, excluded_file
    end
  end

  def test_call_only_includes_rb_and_erb_files
    Dir.mktmpdir do |dir|
      ruby_file = File.join(dir, "app/models/user.rb")
      erb_file = File.join(dir, "app/views/users/show.html.erb")
      text_file = File.join(dir, "app/views/users/show.txt")
      js_file = File.join(dir, "app/javascript/users.js")

      [ruby_file, erb_file, text_file, js_file].each do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "# test\n")
      end

      collector = Stellwerk::SourceFileCollector.new(dir)

      files = collector.call.map(&:to_s)

      assert_includes files, ruby_file
      assert_includes files, erb_file
      refute_includes files, text_file
      refute_includes files, js_file
    end
  end
end
