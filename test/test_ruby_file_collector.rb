# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class TestRubyFileCollector < Minitest::Test
  def test_call_filters_out_excluded_directories
    Dir.mktmpdir do |dir|
      allowed_file = File.join(dir, "app/models/user.rb")
      excluded_db_file = File.join(dir, "db/schema.rb")
      excluded_vendor_file = File.join(dir, "vendor/gems/foo.rb")

      [allowed_file, excluded_db_file, excluded_vendor_file].each do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "# test\n")
      end

      collector = Stellwerk::RubyFileCollector.new(dir, exclude_paths: ["db/", "vendor/"])

      files = collector.call.map(&:to_s)

      assert_includes files, allowed_file
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

      collector = Stellwerk::RubyFileCollector.new(dir, exclude_paths: ["vendor/"])

      files = collector.call.map(&:to_s)

      assert_includes files, included_file
      refute_includes files, excluded_file
    end
  end
end
