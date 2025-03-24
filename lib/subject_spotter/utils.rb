# frozen_string_literal: true

module SubjectSpotter
  # The module provides utility methods and core functionality to interact with external services,
  # fetch resources (from URLs or local file paths), and perform text processing tasks.
  # This module is designed to be used as part of the SubjectSpotter application or gem.
  #
  # Example usage:
  #   response_body = SubjectSpotter::Utils.get_content_from_path('https://example.com/data.json')
  #   # Or for local files:
  #   file_content = SubjectSpotter::Utils.get_content_from_path('/path/to/local/file.txt')
  class Utils
    # Retrieves the content from a given path, which can either be a URL or a local file path.
    #
    # @param path [String] The path to retrieve content from. This can either be a URL or a local file path.
    # @return [String] The content from the given URL or file, encoded as UTF-8.
    # @raise [RuntimeError] If the URL cannot be fetched or the file does not exist.
    #
    # This method handles both remote and local paths:
    # - For URLs, it makes an HTTP GET request and returns the response body if successful.
    # - For local file paths, it reads and returns the file content.
    def self.get_content_from_path(path)
      if url?(path)
        response = Net::HTTP.get_response(URI(path))

        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to fetch subjects JSON: #{response.code} #{response.message}"
        end

        response.body.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      elsif File.exist?(path)
        File.read(path, encoding: "UTF-8")
      else
        raise "Invalid path provided: #{path}"
      end
    end

    # Determines whether the given path is a URL.
    #
    # @param path [String] The path to check.
    # @return [Boolean] Returns `true` if the path is a URL, otherwise `false`.
    def self.url?(path)
      path.match?(URI::DEFAULT_PARSER.make_regexp)
    end
  end
end
