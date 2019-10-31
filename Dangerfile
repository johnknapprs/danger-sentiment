# Rules for PullRequests using danger.systems/ruby

# Jira Issue Linking
jira.check(
  key: ['KEY', 'PM'],
  url: 'https://myjira.atlassian.net/browse',
  search_title: true,
  search_commits: false,
  fail_on_warning: false,
  report_missing: true,
  skippable: true
)

Dir['fastlane/reports/*.xml'].each do |file|
  junit.parse(file)
  junit.report
end

# sentiment.warn_on_mondays

# sentiment.analyze
