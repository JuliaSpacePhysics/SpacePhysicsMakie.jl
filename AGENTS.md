# Agent Rules and Preferences

## Version Control
- Use Jujutsu (jj) for version control instead of git
- Use `jj new` to create separate commits for different purposes
- When triggering Julia package registration, comment on the commit page of the version bump commit with `@JuliaRegistrator register()`

## Version Bumping
- Use patch version bumps unless breaking changes are introduced or explicitly requested
- Push version bumps directly to main after rebasing (avoid PRs for version bumps)

## Pull Request Workflow
1. Check PR status and wait for all checks to pass before merging
2. Merge PRs when all checks are successful (prefer `squash and merge`)
3. Delete the branch after merging.
4. Fetch from github `jj git fetch` and rebase new commits to main.

## Commit Messages
- Follow conventional commit format
