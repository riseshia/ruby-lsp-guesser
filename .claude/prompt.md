# Project-Specific Instructions

## TodoWrite Usage Guidelines

**When NOT to use TodoWrite** (skip for simple tasks):
1. Single file edits with 1-2 clear steps
2. Simple bug fixes in one location
3. Rubocop/linting fixes
4. Adding missing files to git
5. Straightforward refactoring

**When TO use TodoWrite** (only for complex work):
1. 3+ distinct files need changes
2. Multiple independent systems affected
3. User explicitly lists multiple tasks
4. Complex multi-step requiring research + design + implementation
5. Debugging unclear issues

**Rule**: Can you complete in one focused session without tracking? → No TodoWrite

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

## Linter-First Strategy

**CRITICAL**: Run linter BEFORE committing to avoid separate "fix linting" commits.

**Workflow**:
1. After editing any Ruby file, run: `bin/rubocop <file_path>`
2. If violations found, fix them immediately
3. Commit once with all changes together (code + linting fixes)

**Benefits**:
- Reduces commits from 3 to 1
- Avoids cluttering git history
- Catches issues early

**Never create separate "Fix rubocop" commits** - always fix linting issues in the same commit as the code change.

## Atomic Commit Strategy

**Group related changes into single commits**:

✅ **Good** - Single commit:
- "Filter hover to constants and variables only"
  - Changed dispatcher calls
  - Updated handlers
  - Fixed Rubocop violations
  - Added binstubs

❌ **Bad** - Multiple commits:
- "Filter hover..."
- "Fix rubocop..."
- "Add binstub..."

**Pre-commit checklist**:
1. Run linter on changed files
2. Run tests
3. Check for untracked files that should be included
4. Make ONE commit with all related changes

## Parallel Execution Rules

**ALWAYS execute operations in parallel when there are no dependencies**:

✅ **Must parallelize**:
1. Reading multiple files: `Read(file1.rb) + Read(file2.rb)` together
2. Git inspection: `git status + git diff + git log` together
3. Independent searches: `Glob + Grep` together

❌ **Only sequential when TRUE dependencies exist**:
- Edit needs Read first (tool requirement)
- Push needs commit first (data dependency)
- Commit needs tests to pass first

**Performance benefit**: Parallel execution reduces time by 40-60%

## Implementation Task Checklist

**Before starting any implementation**:

□ Clarify ambiguous terms - Ask before assuming
□ Check for `/go` command in plan.md
□ Read relevant files in parallel
□ Decide on TodoWrite - Only if multi-step/complex (3+ files)
□ Make changes
□ Run linter BEFORE commit (bin/rubocop)
□ Run tests (rake test)
□ Single atomic commit with all related changes
□ Check for untracked files
□ Push to remote

**Time estimates**:
- Simple change: ~5 messages
- Medium refactor: ~10 messages
- Complex feature: Use `/go` command

**If exceeding estimates, you may be over-complicating the task.**
