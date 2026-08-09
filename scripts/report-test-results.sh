#!/usr/bin/env bash
set -uo pipefail

# Renders an .xcresult bundle as Markdown for the GitHub Actions job summary.
# Usage: bash scripts/report-test-results.sh [result-bundle.xcresult]
# Writes to $GITHUB_STEP_SUMMARY when set, otherwise stdout.

RESULT_BUNDLE="${1:-${RESULT_BUNDLE:?RESULT_BUNDLE is required}}"
JOB_LABEL="${JOB_LABEL:-$(basename "$RESULT_BUNDLE" .xcresult)}"
TEST_OUTCOME="${TEST_OUTCOME:-unknown}"
SUMMARY_OUT="${GITHUB_STEP_SUMMARY:-/dev/stdout}"
WORK_DIR="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"

{
  echo "## Test results — \`$JOB_LABEL\`"
  echo
} >> "$SUMMARY_OUT"

if [[ ! -e "$RESULT_BUNDLE" ]]; then
  echo "No result bundle produced (\`xcodebuild test\` outcome: \`$TEST_OUTCOME\`)." >> "$SUMMARY_OUT"
  exit 0
fi

SUMMARY_JSON="$WORK_DIR/test-summary-$JOB_LABEL.json"
TESTS_JSON="$WORK_DIR/test-tests-$JOB_LABEL.json"

if ! xcrun xcresulttool get test-results summary --path "$RESULT_BUNDLE" --compact > "$SUMMARY_JSON"; then
  echo "Could not read the result bundle with \`xcresulttool\` (\`xcodebuild test\` outcome: \`$TEST_OUTCOME\`)." >> "$SUMMARY_OUT"
  exit 0
fi

jq -r '
  def num(x): (x // 0);
  "| Result | Total | Passed | Failed | Skipped | Expected failures |",
  "| :--- | ---: | ---: | ---: | ---: | ---: |",
  "| \(.result // "unknown") | \(num(.totalTestCount)) | \(num(.passedTests)) | \(num(.failedTests)) | \(num(.skippedTests)) | \(num(.expectedFailures)) |",
  "",
  ((.environmentDescription // "") | if . == "" then empty else "_\(.)_" end)
' "$SUMMARY_JSON" >> "$SUMMARY_OUT"

jq -r '
  def cell: (. // "") | gsub("\r"; "") | gsub("\n"; "<br>") | gsub("\\|"; "\\|");
  ((.testFailures // []) | if type == "array" then . else [.] end) as $failures
  | if ($failures | length) == 0 then empty
    else
      "", "### Failures", "",
      "| Test | Target | Message |", "| :--- | :--- | :--- |",
      ($failures[] | "| `\(.testName // "unknown" | cell)` | \(.targetName // "unknown" | cell) | \(.failureText | cell) |")
    end
' "$SUMMARY_JSON" >> "$SUMMARY_OUT"

if xcrun xcresulttool get test-results tests --path "$RESULT_BUNDLE" --compact > "$TESTS_JSON"; then
  jq -r '
    def icon:
      if . == "Passed" then "✅"
      elif . == "Failed" then "❌"
      elif . == "Skipped" then "⏭️"
      elif . == "Expected Failure" then "⚠️"
      else "❔" end;
    def cell: (. // "") | gsub("\\|"; "\\|");
    def is_group: . == "Test Suite" or . == "Unit test bundle" or . == "UI test bundle";
    def cases($suite):
      .[]? as $node
      | if $node.nodeType == "Test Case"
        then {
          suite: $suite,
          name: $node.name,
          result: ($node.result // "unknown"),
          duration: ($node.duration // "—")
        }
        else ($node.children | cases(if ($node.nodeType | is_group) then $node.name else $suite end))
        end;
    [.testNodes | cases("")] as $cases
    | if ($cases | length) == 0 then empty
      else
        "", "<details><summary>All tests (\($cases | length))</summary>", "",
        "| | Test | Suite | Duration |", "| :--- | :--- | :--- | ---: |",
        ($cases
          | sort_by([(.result == "Passed"), .suite, .name])[]
          | "| \(.result | icon) | `\(.name | cell)` | \(.suite | cell) | \(.duration | cell) |"),
        "", "</details>"
      end
  ' "$TESTS_JSON" >> "$SUMMARY_OUT"
fi
