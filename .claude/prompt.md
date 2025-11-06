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

**CRITICAL**: When the user asks you to implement ANY feature or fix ANY bug:

1. **ALWAYS use the `/go` command first** - Do not implement directly
2. The `/go` command will automatically:
   - Find the next unmarked test in `plan.md`
   - Mark it as [~] (in progress)
   - Write the test first (Red phase)
   - Implement minimal code to pass (Green phase)
   - Refactor if needed (Refactor phase)
   - Mark it as [x] (completed)
   - Commit with clear message indicating structural or behavioral change
3. If no test exists in `plan.md`, ask the user if you should add it first

**Examples of when to use `/go`**:
- "구현해줘" / "implement this"
- "이 기능 추가해줘" / "add this feature"
- "버그 고쳐줘" / "fix this bug"
- "코드 작성해줘" / "write this code"
- Any request that involves writing or modifying code

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
