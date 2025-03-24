# frozen_string_literal: true

module SubjectSpotter
  module Serializer
    CSV_HEADERS = [
      "Subject ID",
      "Canonical Subject Name/Title",
      "Verbatim Text",
      "Preceding 30 Characters",
      "Following 30 Characters",
      "XPath Location"
    ].freeze

    # The Serializer module provides functionality for serializing subject-related data
    # extracted from a raw output (e.g., HTML) into various formats such as HTML, CSV, or JSON.
    #
    # Example usage:
    #   serializer = SubjectSpotter::Serializer::Base.new(raw_output: "<html>...</html>")
    #   html_output = serializer.output(format: :html)
    #   csv_output = serializer.output(format: :csv)
    #   json_output = serializer.output(format: :json)
    #
    # The class provides the following functionalities:
    # - Parsing raw HTML content.
    # - Extracting subject-related entities (e.g., subject names, text, and metadata).
    # - Serializing data into HTML, CSV, and JSON formats.
    class Base
      # Initializes a new serializer instance with the provided raw output.
      #
      # @param raw_output [String] The raw output HTML to parse and extract data from.
      # @raise [ArgumentError] If raw_output is not a valid string or is empty.
      def initialize(raw_output: "")
        @raw_output = raw_output

        @n_characters = ENV.fetch("N_CHARACTERS", 30)
      end

      # Sets the raw output and clears any cached serialized data.
      #
      # @param string [String] The new raw output to be set.
      def raw_output=(string)
        @raw_output = string

        remove_instance_variable(:@doc) if defined?(@doc)
        remove_instance_variable(:@entities) if defined?(@entities)
        remove_instance_variable(:@serialized_html) if defined?(@serialized_html)
        remove_instance_variable(:@serialized_csv) if defined?(@serialized_csv)
      end

      # Returns the serialized output in the requested format.
      #
      # @param format [Symbol] The desired format for the serialized output.
      #   Accepts :html, :csv, or :json.
      # @return [String] The serialized output in the requested format.
      # @raise [NotImplementedError] If an unsupported format is requested.
      def output(format:)
        case format
        when :html
          serialized_html
        when :csv
          serialized_csv
        when :json
          serialized_json
        else
          raise NotImplementedError
        end
      end

      # Returns a collection of entities (subjects) extracted from the raw output.
      #
      # @return [Array<Hash>] An array of hashes representing the extracted entities.
      #   Each hash contains keys such as :id, :name, :text, :preceding_text, :trailing_text, and :xpath_location.
      def entities
        return @entities if defined?(@entities)

        @entities = []
        doc.css("a").each do |subject|
          id = subject["id"]
          name = subject["title"]
          text = subject.text.strip

          preceding_text = doc.to_html[0..doc.to_html.index(subject.to_html) - 1].slice(-@n_characters, @n_characters)
          trailing_text = doc.to_html[doc.to_html.index(subject.to_html) + subject.to_html.length..doc.to_html.length]
                             .slice(0, @n_characters)

          xpath_location = doc.xpath("//a[@id='#{id}']").to_s

          @entities << {
            id:,
            name:,
            text:,
            preceding_text:,
            trailing_text:,
            xpath_location:
          }
        end

        @entities
      end

      private

      # Parses the raw HTML output and returns a Nokogiri document.
      #
      # @return [Nokogiri::HTML::Document] The parsed HTML document.
      def doc
        @doc ||= Nokogiri::HTML(@raw_output)
      end

      # Serializes the extracted entities into an HTML format.
      #
      # @return [String] The HTML representation of the entities.
      def serialized_html
        @serialized_html ||= doc.to_html(indent: 2)
      end

      # Serializes the extracted entities into a CSV format.
      #
      # @return [String] The CSV representation of the entities.
      def serialized_csv
        return @serialized_csv if defined?(@serialized_csv)

        @serialized_csv = CSV.generate(force_quotes: true) do |csv_string|
          csv_string << CSV_HEADERS

          entities.each do |entity|
            csv_string << [
              entity[:id],
              entity[:name],
              entity[:text],
              entity[:preceding_text],
              entity[:trailing_text],
              entity[:xpath_location]
            ]
          end
        end

        @serialized_csv
      end

      # Serializes the extracted entities into a JSON format.
      #
      # @return [String] The JSON representation of the entities.
      def serialized_json
        @serialized_json ||= JSON.pretty_generate(entities)
      end
    end
  end
end
