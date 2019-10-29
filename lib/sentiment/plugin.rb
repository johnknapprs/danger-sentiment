# frozen_string_literal: true

module Danger
  require "google/cloud/language"

  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  John Knapp/danger-sentiment
  # @tags monday, weekends, time, rattata
  #
  class DangerSentiment < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #

    class MissingConfiguredError < StandardError
      def initialize(msg = 'You must call sentiment.configure before sentiment.evaluate can be used')
        super
      end
    end

    # This is a descriptiong of this method
    # @return  [void]
    def credentials_json(value = "#{ENV['HOME']}/key.json")
      File.exist?(value)
    end

    # This is a descriptiong of this method
    # https://github.com/dbgrandi/danger-prose/blob/v2.0.0/lib/danger_plugin.rb#L40#-L41
    # @return  [void]
    def warn_on_mondays
      warn "Trying to merge code on a Monday" if Date.today.wday == 1
    end

    # Analyze all PR issues
    # Will post a table of results per message/user

    def analyze
      require 'awesome_print'

      repo_name = github.pr_json.base.repo.full_name

      issues = github.api.issue_comments(repo_name, 1)
      issues = remove_default_comments(issues)
      issues = create_comments_hash(issues)

      # warn('found key.json in home directory, attempting to authenticate') unless credentials_json

      issues.each do |i|
        require 'rest-client'

        text_content = i[:comment_body]

        response = RestClient.post "https://apis.paralleldots.com/v4/sentiment", { api_key: ENV['PARALLEL_DOTS_API_KEY'], text: text_content }
        response = JSON.parse(response)

        formatted_response = []
        formatted_response << "| sentiment | score |"
        formatted_response << "|---|---|"

        formatted_response << response['sentiment'].map do |k, v|
          "| #{k} | #{v} |"
        end

        formatted_response = formatted_response.join("\n")

        markdown("Username: #{i[:username]}\nMessage: #{text_content}\n\n#{formatted_response}\n")
      end
    end

    private

    def remove_default_comments(pr_comments)
      pr_comments.reject { |c| c.body.include?('<!--') }
    end

    def create_comments_hash(pr_comments)
      pr_comments.collect do |c|
        {
          username: c.user.login,
          comment_id: c.id,
          comment_body: c.body
        }
      end
    end
  end
end
