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

junit.parse('fastlane/reports/junit.xml')
junit.report

# sentiment.warn_on_mondays

sentiment.analyze
