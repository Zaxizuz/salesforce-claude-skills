# Salesforce Claude Skills

A collection of specialized skills for Claude Code to assist with professional Salesforce development.

## Overview

This repository contains three coordinated skills for comprehensive Salesforce development:

1. **salesforce-apex** - Core Apex development with best practices
2. **salesforce-qa** - Quality assurance and code review
3. **salesforce-orchestrator** - Workflow orchestration across agents

## Skills

### 1. Salesforce Apex (`salesforce-apex/`)

**Purpose**: Professional Apex code development following Salesforce best practices.

**Use when:**
- Writing triggers, classes, batch jobs
- Implementing business logic
- Creating test classes
- Handling governor limits
- Optimizing performance

**Includes:**
- Trigger handler patterns
- Service layer patterns
- Test class templates
- Common utilities
- SFDX test runner script

**Best practices covered:**
- Bulkification
- Governor limits
- Error handling
- Security (CRUD/FLS)
- Asynchronous patterns
- Testing strategies

### 2. Salesforce QA (`salesforce-qa/`)

**Purpose**: Comprehensive quality assurance and code review.

**Use when:**
- Reviewing Apex code
- Validating test coverage
- Checking security practices
- Ensuring best practices
- Pre-deployment validation

**Review areas:**
- Bulkification & governor limits
- Security (CRUD/FLS, sharing)
- Error handling
- Test coverage quality
- Code organization
- Performance optimization
- Documentation

**Outputs:**
- Detailed review reports
- Categorized issues (Critical/Major/Minor)
- Specific recommendations
- Approval status

### 3. Salesforce Orchestrator (`salesforce-orchestrator/`)

**Purpose**: Coordinate development workflow across multiple agents.

**Use when:**
- Managing complex development tasks
- Need multi-agent coordination
- Want systematic quality gates
- Integrating with Salesforce Vibe
- Ensuring production-ready code

**Workflow:**
1. Analyze requirements
2. Plan approach
3. Salesforce Vibe (code generation)
4. Apex agent (best practices)
5. QA agent (validation)
6. Iterate if needed
7. Deliver production-ready code

## Installation

### Option 1: Clone to Project Directory

```bash
cd your-salesforce-project
git clone https://github.com/your-username/salesforce-claude-skills.git .claude-skills
```

### Option 2: Global Installation

```bash
git clone https://github.com/your-username/salesforce-claude-skills.git ~/salesforce-claude-skills
```

Then reference from any Salesforce project.

### Option 3: Upload to Claude Code

1. Package skills using the packaging script
2. Upload .skill files directly to Claude Code

## Usage in Claude Code

### Using Individual Skills

**Example: Apex Development**
```
"Using the salesforce-apex skill, create a trigger handler for Account 
that updates related Opportunities when Account Status changes."
```

**Example: Code Review**
```
"Using the salesforce-qa skill, review this Apex class for best practices 
and security issues:
[paste code]"
```

### Using the Orchestrator

**Example: End-to-End Development**
```
"Using the salesforce-orchestrator skill, develop a complete solution for:
- Prevent Account deletion if there are related Closed Won Opportunities
- Include trigger, handler, test class
- Coordinate with Salesforce Vibe for initial generation
- Ensure all best practices and quality gates are met"
```

## File Structure

```
salesforce-claude-skills/
├── README.md (this file - not part of skills)
├── salesforce-apex/
│   ├── SKILL.md (main skill file)
│   ├── scripts/
│   │   └── run-tests.sh (SFDX test runner)
│   └── references/
│       ├── trigger-handler-base.md
│       └── apex-utilities.md
├── salesforce-qa/
│   └── SKILL.md
└── salesforce-orchestrator/
    └── SKILL.md
```

## Customization

### Adding Org-Specific Patterns

Create `references/org-patterns.md` in the `salesforce-apex/` skill:

```markdown
# Our Org Patterns

## Naming Conventions
- Trigger handlers: [Object]TriggerHandler
- Service classes: [Object]Service
- Test classes: [ClassName]Test

## Custom Metadata
- API_Configuration__mdt for endpoint URLs
- Error_Notification__mdt for alerting

## Logging Framework
Use ErrorLogger.log() for all exceptions
```

### Adding Custom Scripts

Add your own utility scripts to `salesforce-apex/scripts/`:

```bash
# Example: deploy.sh
#!/bin/bash
sf project deploy start --target-org production --manifest package.xml
```

## Best Practices

### 1. Start with the Orchestrator
For complex tasks, let the orchestrator coordinate the workflow.

### 2. Iterate Based on QA Feedback
Don't ignore QA findings - use them to improve code quality.

### 3. Maintain Context
When moving between agents, provide full context and requirements.

### 4. Customize for Your Org
Add org-specific patterns, naming conventions, and standards.

### 5. Keep Skills Updated
As you discover new patterns, add them to reference files.

## Contributing

To improve these skills:

1. Add new patterns to reference files
2. Create additional scripts for common tasks
3. Update SKILL.md with lessons learned
4. Share improvements back to the repository

## Version Control

Recommended workflow:
1. Fork this repository
2. Customize for your org
3. Version control your customizations
4. Pull updates from main repo periodically

## Support

For issues or questions:
- Check skill documentation in SKILL.md files
- Review reference files for examples
- Consult Salesforce best practices documentation

## License

[Your License Here]

## Acknowledgments

Built following Anthropic's skill creation best practices for Claude Code.
