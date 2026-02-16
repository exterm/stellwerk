require "pathname"

module Stellwerk
  class SourceFileCollector
    EXCLUDED_PATHS = ["db/", "vendor/"]
    SOURCE_FILE_EXTENSIONS = [".rb", ".erb"]

    def initialize(root_path, exclude_paths: EXCLUDED_PATHS)
      @root_path = Pathname.new(root_path)
      @exclude_paths = exclude_paths
    end

    def call
      absolute_exclude_paths = @exclude_paths.map do |path|
        @root_path.join(path).to_s.delete_suffix(File::SEPARATOR)
      end

      @root_path.find
        .select { |path| source_file?(path) }
        .reject { |path| excluded_path?(path.to_s, absolute_exclude_paths) }
    end

    private

    def source_file?(path)
      SOURCE_FILE_EXTENSIONS.include?(path.extname)
    end

    def excluded_path?(path_str, absolute_exclude_paths)
      absolute_exclude_paths.any? do |exclude_path|
        path_str == exclude_path || path_str.start_with?("#{exclude_path}#{File::SEPARATOR}")
      end
    end
  end
end
