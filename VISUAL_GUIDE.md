# Salesforce Claude Skills - Visual Workflow Guide

## 📁 Complete File Structure

```
salesforce-claude-skills/
│
├── 📄 README.md                                    # Repository overview & documentation
│
├── 🔧 salesforce-apex/                             # APEX DEVELOPMENT SKILL
│   ├── 📄 SKILL.md                                 # Main skill (3,800+ lines)
│   │   ├── Development workflow
│   │   ├── Core principles (bulkification, limits)
│   │   ├── Code patterns (triggers, service, selector)
│   │   ├── Asynchronous patterns (batch, queueable)
│   │   ├── Error handling
│   │   ├── Security (CRUD/FLS)
│   │   └── Best practices checklist
│   │
│   ├── 📁 scripts/
│   │   └── 🔨 run-tests.sh                        # SFDX test automation
│   │
│   └── 📁 references/
│       ├── 📄 trigger-handler-base.md             # Base handler class
│       ├── 📄 apex-utilities.md                   # Utility methods library
│       └── 📄 org-patterns.md                     # ⭐ Customize for your org
│
├── ✅ salesforce-qa/                               # QA & CODE REVIEW SKILL
│   └── 📄 SKILL.md                                 # Main skill (2,500+ lines)
│       ├── QA workflow (8 steps)
│       ├── Code review checklist
│       ├── Security review
│       ├── Test coverage validation
│       ├── Performance analysis
│       ├── Report format template
│       └── Approval criteria
│
└── 🎯 salesforce-orchestrator/                     # ORCHESTRATION SKILL
    └── 📄 SKILL.md                                 # Main skill (2,800+ lines)
        ├── 7-step workflow
        ├── Multi-agent coordination
        ├── Salesforce Vibe integration
        ├── Quality gates
        ├── Iteration patterns
        └── Complete examples
```

---

## 🔄 Workflow Diagrams

### Simple Development (Direct to Apex Agent)

```
┌─────────────┐
│ User Request│
│   "Create   │
│   trigger"  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ salesforce-apex │
│   - Generates   │
│   - Applies     │
│     patterns    │
│   - Tests       │
└────────┬────────┘
         │
         ▼
    ┌────────┐
    │  Done  │
    │  ✅    │
    └────────┘
```

**Use when:** 
- Simple code generation
- Quick utilities
- Already familiar with best practices

---

### Code Review (Direct to QA Agent)

```
┌─────────────┐
│ User Request│
│  "Review    │
│  my code"   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  salesforce-qa  │
│   - Analyzes    │
│   - Validates   │
│   - Reports     │
└────────┬────────┘
         │
         ▼
    ┌────────────┐
    │   Report   │
    │ Critical/  │
    │ Major/Minor│
    │  Issues    │
    └──────┬─────┘
           │
           ▼
    If Issues Found
           │
           ▼
    ┌──────────────┐
    │salesforce-   │
    │apex (fix)    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │salesforce-qa │
    │(re-validate) │
    └──────┬───────┘
           │
           ▼
       ┌────────┐
       │  Done  │
       │  ✅    │
       └────────┘
```

**Use when:**
- Reviewing existing code
- Pre-deployment validation
- Learning from mistakes

---

### Complex Development (Orchestrated)

```
┌──────────────────────┐
│   User Request       │
│ "Build complete      │
│  feature with        │
│  Salesforce Vibe"    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  salesforce-         │
│  orchestrator        │
│  (analyzes request)  │
└──────────┬───────────┘
           │
           ▼
    ┌──────────────┐
    │ STEP 1:      │
    │ Analyze      │
    │ Requirements │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ STEP 2:      │
    │ Plan         │
    │ Approach     │
    └──────┬───────┘
           │
           ▼
    ┌──────────────────┐
    │ STEP 3:          │
    │ Salesforce Vibe  │◄────┐
    │ (generate code)  │     │
    └──────┬───────────┘     │
           │                 │
           ▼                 │
    ┌──────────────────┐    │
    │ STEP 4:          │    │
    │ salesforce-apex  │    │
    │ (enhance with    │    │
    │  best practices) │    │
    └──────┬───────────┘    │
           │                 │
           ▼                 │
    ┌──────────────────┐    │
    │ STEP 5:          │    │
    │ salesforce-qa    │    │
    │ (validate code)  │    │
    └──────┬───────────┘    │
           │                 │
           ▼                 │
    ┌──────────────┐        │
    │ Issues Found?│        │
    └──────┬───────┘        │
           │                 │
      YES  │  NO             │
           │  │              │
           ▼  │              │
    ┌──────────────┐        │
    │ STEP 6:      │        │
    │ Iterate      │────────┘
    │ (fix issues) │
    └──────────────┘
           │
           │ NO MORE ISSUES
           ▼
    ┌──────────────┐
    │ STEP 7:      │
    │ Finalize     │
    │ & Deliver    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────────┐
    │ Production-Ready │
    │      Code        │
    │       ✅         │
    └──────────────────┘
```

**Use when:**
- Building complete features
- Need quality assurance
- Working with Salesforce Vibe
- Complex business logic
- Mission-critical code

---

## 🎯 Decision Tree: Which Skill to Use?

```
                    START
                      │
                      ▼
            ┌─────────────────┐
            │ What do you     │
            │ need to do?     │
            └────┬────────┬───┘
                 │        │
        ┌────────┘        └────────┐
        │                           │
        ▼                           ▼
┌───────────────┐          ┌────────────────┐
│ Review        │          │ Write/Build    │
│ Existing Code │          │ New Code       │
└───────┬───────┘          └────────┬───────┘
        │                           │
        ▼                           ▼
┌───────────────┐          ┌────────────────┐
│ USE:          │          │ Is it complex? │
│ salesforce-qa │          └────┬──────┬────┘
└───────────────┘               │      │
                               NO     YES
                                │      │
                                ▼      ▼
                    ┌──────────────┐  ┌─────────────────┐
                    │ USE:         │  │ USE:            │
                    │ salesforce-  │  │ salesforce-     │
                    │ apex         │  │ orchestrator    │
                    └──────────────┘  └─────────────────┘
```

---

## 🔑 Quality Gates

```
┌────────────────────────────────────────────────────┐
│                  QUALITY GATES                     │
├────────────────────────────────────────────────────┤
│                                                    │
│  Gate 1: Functional Correctness                   │
│  ✓ Code does what it's supposed to do            │
│  ✓ Business logic implemented                     │
│  └─ Validated by: Salesforce Vibe / Apex Agent   │
│                                                    │
│  Gate 2: Best Practices                           │
│  ✓ Bulkified code                                │
│  ✓ Governor limits respected                      │
│  ✓ Proper patterns applied                        │
│  └─ Validated by: salesforce-apex agent          │
│                                                    │
│  Gate 3: Security                                  │
│  ✓ CRUD/FLS checked                               │
│  ✓ Sharing rules applied                          │
│  ✓ Input sanitized                                │
│  └─ Validated by: salesforce-qa agent            │
│                                                    │
│  Gate 4: Test Coverage                            │
│  ✓ ≥90% code coverage                            │
│  ✓ Meaningful assertions                          │
│  ✓ Bulk testing (200+ records)                   │
│  └─ Validated by: salesforce-qa agent            │
│                                                    │
│  Gate 5: Production Readiness                     │
│  ✓ Documentation complete                         │
│  ✓ Error handling comprehensive                   │
│  ✓ All critical issues resolved                   │
│  └─ Validated by: orchestrator final review      │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 📊 Code Quality Scoring

```
┌─────────────────────────────────────┐
│      QA REVIEW SCORING              │
├─────────────────────────────────────┤
│                                     │
│  10/10  ✅ Perfect                 │
│   └─ Zero issues                   │
│   └─ Exemplary code                │
│                                     │
│  8-9/10 ✅ Approved                │
│   └─ Minor issues only             │
│   └─ Production ready              │
│                                     │
│  6-7/10 ⚠️  Approved with Changes  │
│   └─ Some major issues             │
│   └─ Fix before deploy             │
│                                     │
│  4-5/10 ⚠️  Needs Revision         │
│   └─ Multiple major issues         │
│   └─ Refactor required             │
│                                     │
│  0-3/10 ❌ Rejected                │
│   └─ Critical issues               │
│   └─ Complete redesign needed      │
│                                     │
└─────────────────────────────────────┘
```

---

## 🚀 Quick Command Reference

### For Writing Code
```bash
"Using salesforce-apex, create a trigger handler for Contact 
that validates email format and prevents duplicate emails"
```

### For Reviewing Code
```bash
"Using salesforce-qa, review this Apex class for security 
issues, bulkification problems, and test coverage:

[paste code]"
```

### For Complete Development
```bash
"Using salesforce-orchestrator, build a complete solution:
- Account trigger preventing deletion with active Opportunities
- Email notification to Account Owner
- Complete test coverage
- Work with Salesforce Vibe for initial generation
- Ensure all quality gates pass"
```

---

## 📚 Learning Path

```
┌─────────────────────────────────────────────┐
│          RECOMMENDED LEARNING PATH          │
├─────────────────────────────────────────────┤
│                                             │
│  Week 1: Start Simple                       │
│  └─ Use salesforce-apex for utilities      │
│  └─ Review patterns in references/         │
│                                             │
│  Week 2: Add Quality Checks                 │
│  └─ Use salesforce-qa to review code       │
│  └─ Learn from feedback                    │
│                                             │
│  Week 3: Customize                          │
│  └─ Update org-patterns.md                 │
│  └─ Add your standards                     │
│                                             │
│  Week 4: Orchestrate                        │
│  └─ Use orchestrator for features          │
│  └─ Integrate Salesforce Vibe              │
│                                             │
│  Ongoing: Iterate & Improve                 │
│  └─ Add new patterns learned               │
│  └─ Share with team                        │
│  └─ Version control changes                │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🎓 Success Metrics

Track your improvement:

```
Week 1 Baseline:
□ Code review finds 10+ issues
□ Test coverage ~60%
□ Manual quality checks

After 1 Month:
□ Code review finds 3-5 issues
□ Test coverage ~85%
□ Automated quality gates

After 3 Months:
□ Code review finds 0-2 issues
□ Test coverage ~95%
□ Production deployments smooth
□ Team using shared skills
```

---

## 🔗 Resources Provided

✅ **3 Complete Skills**
- salesforce-apex (development)
- salesforce-qa (review)
- salesforce-orchestrator (coordination)

✅ **4 Reference Documents**
- Trigger handler base class
- Apex utilities library
- Org patterns template
- Complete README

✅ **1 Automation Script**
- SFDX test runner

✅ **2 Getting Started Guides**
- QUICK_START.md
- SUMMARY.md

✅ **Ready for GitHub**
- Proper structure
- Version control ready
- Team collaboration enabled

---

**🎉 Everything you need to build production-ready Salesforce code with Claude Code!**
