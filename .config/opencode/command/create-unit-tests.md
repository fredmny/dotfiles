---
description: Create Unit Tests
agent: build
---

# Create or Update Unit Tests

Analyze the changes between the current branch and the base branch, then create or update unit tests accordingly and run the tests, ensuring thy're running successfully.


## Instructions

1. **Identify Changes**: Compare the current branch with the base branch to identify all modified, added, or deleted code.

2. **Analyze Existing Tests**: Before creating new tests, examine existing test files in the project to understand:
   - Test file naming conventions
   - Test framework being used
   - Test structure and organization patterns
   - Assertion styles and helper utilities
   - Mocking and fixture patterns

3. **Follow Project Patterns**: New or updated tests MUST follow the same patterns as other tests in the project:
   - Use the same test framework and assertion library
   - Match the existing file and folder structure
   - Follow the same naming conventions for test files, test suites, and test cases
   - Use similar setup/teardown patterns
   - Apply consistent mocking strategies

4. **Test Coverage Requirements**:
   - Cover all new functions and methods
   - Test edge cases and error conditions
   - Update existing tests if the underlying code behavior has changed
   - Remove or update tests for deleted functionality

5. **Test Quality**:
   - Write clear, descriptive test names that explain what is being tested
   - Keep tests focused and atomic (one assertion per test when practical)
   - Ensure tests are deterministic and independent
   - Avoid testing implementation details; focus on behavior

You should not:

- commit anything or execute any git or Github operations.
- Delete any files or update any code apart from tests.

## Process

1. Identify the base branch (will probably be `develop` or `main`)
2. Run `git diff $(git merge-base HEAD main)..HEAD` to see the changes (adjust base branch name if needed)
3. Locate existing test files to understand project conventions
4. Create or update test files following the identified patterns
5. Ensure all new code paths have appropriate test coverage


