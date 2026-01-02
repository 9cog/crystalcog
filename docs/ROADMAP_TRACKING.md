# Development Roadmap Issues Tracking System

This document describes the automated system for generating GitHub issues from the development roadmap.

## Overview

The CrystalCog project uses an automated GitHub workflow to generate and track issues based on tasks defined in `DEVELOPMENT-ROADMAP.md`. This ensures that roadmap items are properly tracked, assigned, and completed as part of the development process.

## How It Works

### 1. Roadmap Structure

The system expects the roadmap to follow this structure:

```markdown
## Next Steps

### Immediate Actions (Week 1-2)

1. **Complete Core Foundation**
   - ✅ Setup Crystal development environment
   - [ ] Implement new feature
   - Plain task without completion indicator

2. **Another Section**
   - [x] Completed with checkbox
   - [ ] Incomplete with checkbox
```

### 2. Task Formats

The system recognizes three task formats:

- **Checkboxes**: `- [x]` (completed) or `- [ ]` (incomplete)
- **Checkmarks**: `- ✅` (completed)
- **Plain bullets**: `- Task description` (assumed incomplete)

### 3. Automatic Processing

The workflow automatically:

1. **Parses** the roadmap for actionable tasks
2. **Creates** GitHub issues for incomplete tasks
3. **Skips** tasks that are already completed
4. **Labels** issues with appropriate tags
5. **Updates** tracking issues with generation summaries

## Workflow Triggers

The roadmap processing workflow runs automatically:

- **Weekly**: Every Monday at 10 AM UTC
- **On roadmap changes**: When `DEVELOPMENT-ROADMAP.md` is updated
- **Manual trigger**: Via GitHub Actions interface

## Issue Generation

### Labels Applied

All generated issues receive these labels:

- `roadmap` - Identifies roadmap-generated issues
- `crystal-conversion` - Part of the Crystal conversion project
- `priority-{high,medium,low}` - Based on roadmap section
- Component labels (e.g., `cogutil`, `atomspace`, `pln`)
- Section labels (e.g., `immediate-actions`)

### Issue Content

Each generated issue includes:

- **Task description** from the roadmap
- **Context** (section, priority, components)
- **Reference** link to the roadmap
- **Acceptance criteria** checklist
- **Definition of done** requirements

### Priority Assignment

Priorities are assigned based on roadmap sections:

- **High**: "Immediate Actions" sections
- **Medium**: "Phase 2" and "Phase 3" sections  
- **Low**: "Success Metrics" sections

## Validation

### Local Validation

Before committing roadmap changes, validate the structure:

```bash
node scripts/validate-roadmap.js
```

This script will:

- Check roadmap structure and required sections
- Parse and analyze all tasks
- Report task completion statistics
- Identify format issues
- Preview what issues would be generated

### Continuous Validation

The GitHub workflow includes automatic validation:

- Verifies roadmap file exists and has proper structure
- Checks roadmap freshness (warns if >30 days old)
- Validates parsing before issue generation

## Managing Generated Issues

### Completing Tasks

When you complete a roadmap task:

1. **Update the roadmap** - Change task status to completed:
   - `- [ ] Task` → `- [x] Task` 
   - `- Task` → `- ✅ Task`

2. **Close the GitHub issue** - The automated system will skip completed tasks

3. **Reference the issue** - Link commits/PRs to the issue number

### Force Regeneration

To regenerate all issues (e.g., after major roadmap restructuring):

1. Go to **Actions** → **Generate Development Roadmap Issues**
2. Click **Run workflow**
3. Set **Force recreate** to `true`
4. Optionally filter by **roadmap section**

## File Structure

```
.github/
  workflows/
    roadmap-issues.yml          # Main workflow for issue generation
scripts/
  validate-roadmap.js           # Local validation script
docs/
  ROADMAP_TRACKING.md          # This documentation
DEVELOPMENT-ROADMAP.md          # Source roadmap file
```

## Best Practices

### Roadmap Maintenance

1. **Keep tasks actionable** - Use clear, specific descriptions
2. **Update completion status** - Mark tasks as done when completed
3. **Use consistent formatting** - Follow the established patterns
4. **Review regularly** - Keep the roadmap current and relevant

### Issue Management

1. **Assign issues** to team members when created
2. **Link work** - Reference issues in commits and PRs
3. **Update progress** - Use issue comments for status updates
4. **Close when done** - Close issues and update roadmap simultaneously

### Development Workflow

1. **Plan** → Update roadmap with new tasks
2. **Generate** → Let workflow create GitHub issues
3. **Assign** → Assign issues to team members
4. **Implement** → Work on tasks, reference issue numbers
5. **Complete** → Close issue and update roadmap
6. **Repeat** → Continuous improvement cycle

## Troubleshooting

### Common Issues

**No issues generated:**
- Check if all tasks are marked as completed (`✅` or `[x]`)
- Verify roadmap structure with validation script
- Ensure "Next Steps" section exists

**Wrong priority assigned:**
- Check section naming (must include keywords like "Immediate Actions")
- Update priority assignment logic in workflow if needed

**Issues not labeled correctly:**
- Check component keyword detection in workflow
- Ensure task descriptions include relevant keywords

**Duplicate issues:**
- Workflow prevents duplicates based on title matching
- Use "Force recreate" option to rebuild all issues

### Getting Help

1. **Run validation**: `node scripts/validate-roadmap.js`
2. **Check workflow logs** in GitHub Actions
3. **Review issue tracking** summary in issue #28
4. **Update documentation** if you find improvements

## Technical Details

### Workflow Architecture

The roadmap processing consists of three jobs:

1. **verify-roadmap** - Structure validation and freshness check
2. **generate-issues** - Parse roadmap and create/update issues
3. **notify-completion** - Summary reporting

### Parsing Logic

The workflow uses regex patterns to extract:

- Section titles and priorities
- Numbered items with descriptions
- Task lists with various completion formats
- Component keywords for labeling

### Error Handling

The system includes robust error handling:

- Validates roadmap structure before processing
- Skips malformed sections gracefully
- Reports parsing statistics
- Continues processing if individual issues fail

This system ensures that the development roadmap remains a living document that drives actual development work through automated issue tracking.