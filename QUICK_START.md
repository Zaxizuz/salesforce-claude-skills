# Salesforce Claude Skills - Quick Start Guide

## Answers to Your Questions

### 1. What file format?
✅ **SKILL.md** - YAML frontmatter + Markdown body (as provided)

These are the official skill files for Claude Code and follow Anthropic's specification.

### 2. Where to store?
✅ **GitHub Repository** (recommended)

**Setup:**
```bash
# Create a new GitHub repo
gh repo create salesforce-claude-skills --public

# Push your skills
cd salesforce-claude-skills
git init
git add .
git commit -m "Initial commit: Salesforce development skills"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/salesforce-claude-skills.git
git push -u origin main
```

**Use in any project:**
```bash
cd your-salesforce-project
git clone https://github.com/YOUR-USERNAME/salesforce-claude-skills.git .claude-skills
```

### 3. salesforce-apex agent
✅ **Created** - See `salesforce-apex/SKILL.md`

**Includes:**
- Comprehensive Apex development guidance
- Trigger handler patterns
- Service layer patterns
- Test class templates
- Common utilities (references/apex-utilities.md)
- Base trigger handler (references/trigger-handler-base.md)
- Test runner script (scripts/run-tests.sh)
- Org-specific patterns template (references/org-patterns.md)

### 4. salesforce-qa agent
✅ **Created** - See `salesforce-qa/SKILL.md`

**Includes:**
- Comprehensive QA checklist
- Code review criteria
- Security review guidelines
- Test coverage validation
- Performance analysis
- Structured report format
- LWC and Flow review criteria

### 5. salesforce-orchestrator agent
✅ **Created** - See `salesforce-orchestrator/SKILL.md`

**Includes:**
- Multi-agent coordination workflow
- Integration with Salesforce Vibe
- Quality gates enforcement
- Iteration and feedback loops
- Complete end-to-end examples
- Error recovery strategies

## How to Use in Claude Code

### Installation

**Option 1: Local Project (Recommended)**
```bash
cd your-salesforce-project
git clone https://github.com/YOUR-USERNAME/salesforce-claude-skills.git .claude-skills
```

**Option 2: Global Reference**
Keep skills in a central location and reference from multiple projects.

### Using Individual Skills

**Apex Development:**
```
"Using the salesforce-apex skill, create a trigger handler for Account 
that validates the Account Type field and prevents invalid values."
```

**Code Review:**
```
"Using the salesforce-qa skill, review this Apex class:

[paste your code]

Focus on: bulkification, security, test coverage"
```

**Orchestrated Development:**
```
"Using the salesforce-orchestrator skill, build a complete solution:

Requirements:
- Prevent Contact deletion if linked to active Cases
- Send email notification to Contact Owner
- Include all necessary triggers, handlers, and tests
- Coordinate with Salesforce Vibe for initial generation
- Ensure all quality gates pass"
```

## Typical Workflows

### Workflow 1: New Development (Simple)

```
User → Apex Agent → Done
```

**Example:**
```
"Using salesforce-apex, create a utility class with methods to:
1. Calculate business days between two dates
2. Format currency for display
3. Include test class"
```

### Workflow 2: New Development (Complex)

```
User → Orchestrator → Vibe → Apex → QA → Iterate → Done
```

**Example:**
```
"Using salesforce-orchestrator, develop:
- Account trigger preventing deletion with active Opportunities
- Handler with proper patterns
- Service layer for business logic  
- Test class with 100% coverage
- Work with Salesforce Vibe then enhance with best practices"
```

### Workflow 3: Code Review

```
User → QA Agent → (If issues) → Apex Agent → QA Agent → Done
```

**Example:**
```
"Using salesforce-qa, review this code I wrote:

[paste code]

Then if issues found, use salesforce-apex to fix them."
```

### Workflow 4: Refactoring

```
User → Apex Agent → QA Agent → Done
```

**Example:**
```
"Using salesforce-apex, refactor this code to follow best practices:

[paste legacy code]

Then use salesforce-qa to validate the improvements."
```

## Customization Guide

### Add Your Org's Standards

Edit `salesforce-apex/references/org-patterns.md`:

```markdown
## Our Naming Conventions
- Trigger handlers: [Object]TriggerHandler
- Service classes: [Object]Service

## Our Data Model
Account → Custom_Object__c → Related_Object__c

## Our Error Handling
Use ErrorLogger.log() for all exceptions

## Our Testing Requirements
- Minimum coverage: 95% (higher than default 90%)
- Must test with 200+ records
```

### Add Custom Scripts

Add to `salesforce-apex/scripts/`:

```bash
# deploy-to-uat.sh
#!/bin/bash
sf project deploy start --target-org uat --manifest package.xml
```

### Add Reference Documentation

Add to `salesforce-apex/references/`:

- `integration-patterns.md` - Your integration approaches
- `security-guidelines.md` - Additional security rules
- `performance-tuning.md` - Org-specific optimizations

## Best Practices

### ✅ DO:
- Start with orchestrator for complex tasks
- Always run QA review before deployment
- Customize org-patterns.md for your organization
- Version control your customized skills
- Iterate based on QA feedback
- Keep context when moving between agents

### ❌ DON'T:
- Skip QA review even for "simple" changes
- Ignore security warnings
- Deploy code with < 90% coverage
- Hardcode values in generated code
- Mix business logic with trigger code

## Troubleshooting

### "Skills not loading"
- Check that SKILL.md has proper YAML frontmatter
- Ensure files are in correct directory structure
- Verify Claude Code can access the directory

### "Agent not using skill"
- Be explicit: "Using the [skill-name] skill, ..."
- Check that skill description matches your use case
- Ensure SKILL.md description is clear and specific

### "Quality issues still present"
- Run code through QA agent explicitly
- Check QA report for all identified issues
- Iterate: fix issues and re-validate

## File Structure Reference

```
salesforce-claude-skills/
│
├── README.md                          # Repository overview
│
├── salesforce-apex/                   # Apex development skill
│   ├── SKILL.md                       # Main skill file
│   ├── scripts/
│   │   └── run-tests.sh              # SFDX test runner
│   └── references/
│       ├── trigger-handler-base.md   # Base handler pattern
│       ├── apex-utilities.md         # Common utilities
│       └── org-patterns.md           # Customize this!
│
├── salesforce-qa/                     # Quality assurance skill
│   └── SKILL.md                       # Main skill file
│
└── salesforce-orchestrator/           # Orchestration skill
    └── SKILL.md                       # Main skill file
```

## Next Steps

1. **Upload to GitHub**: Version control your skills
2. **Customize**: Edit org-patterns.md with your standards
3. **Test**: Try each skill with real development tasks
4. **Iterate**: Improve based on what works
5. **Share**: Contribute improvements back to the repo

## Example Commands

### For Development
```
"Using salesforce-apex, create a batch class that updates 
all Accounts with LastModifiedDate > 30 days ago"
```

### For Review
```
"Using salesforce-qa, review this trigger handler for 
security issues and governor limit problems"
```

### For Complete Projects
```
"Using salesforce-orchestrator, build a complete integration:
- REST endpoint to receive external data
- Parse JSON and create/update Accounts
- Error handling and logging
- Test class with mock callouts
- Coordinate with Salesforce Vibe"
```

## Support

- Review SKILL.md files for detailed documentation
- Check references/ for examples and patterns
- Consult Salesforce best practices documentation
- Update org-patterns.md with your learnings

---

## Quick Reference Card

| Task | Skill to Use | Example |
|------|--------------|---------|
| Write new Apex code | salesforce-apex | "Create a trigger handler..." |
| Review existing code | salesforce-qa | "Review this code for issues..." |
| Complex development | salesforce-orchestrator | "Build complete solution with..." |
| Enhance Vibe code | salesforce-apex | "Optimize this Vibe-generated code..." |
| Pre-deployment check | salesforce-qa | "Validate this code is production-ready..." |

---

**Remember**: The orchestrator coordinates all agents, ensuring your code follows best practices and passes quality gates before deployment!
