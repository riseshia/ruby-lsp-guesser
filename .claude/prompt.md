# Project-Specific Instructions

## TDD Development Workflow

This project follows strict Test-Driven Development (TDD) practices based on Kent Beck's principles.

**IMPORTANT**: When implementing any code changes:

1. **Always check `plan.md` first** to see if there's a test plan for the feature
2. **Follow the TDD cycle strictly**: Red → Green → Refactor
3. **One test at a time**: Implement one test, make it pass, then move to the next
4. **Run all tests** after each change (use `rake test`)
5. **Commit discipline**: Only commit when all tests pass

### Automatic TDD Mode

When the user asks you to implement a feature or fix a bug:

1. First, check if there's a relevant test in `plan.md`
2. If yes, follow the `/go` command workflow automatically:
   - Find the next unmarked test in `plan.md`
   - Mark it as [~] (in progress)
   - Write the test first (Red phase)
   - Implement minimal code to pass (Green phase)
   - Refactor if needed (Refactor phase)
   - Mark it as [x] (completed)
   - Commit with clear message indicating structural or behavioral change
3. If no test exists in `plan.md`, ask the user if you should add it first

### Code Quality Standards

- Eliminate duplication ruthlessly
- Express intent clearly through naming
- Keep methods small and focused
- Use the simplest solution that works
- Separate structural changes from behavioral changes

### Testing

- Test framework: Minitest
- Run tests: `rake test`
- Test files location: `test/ruby_lsp/`
- Always run tests before committing
