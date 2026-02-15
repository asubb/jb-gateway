## Purpose

OpenSpec integration for spec-driven development with AI agents

## Requirements

### Requirement: OpenSpec CLI availability
The system SHALL provide the OpenSpec CLI tool pre-installed in the container.

#### Scenario: OpenSpec command available
- **WHEN** user runs 'openspec' command
- **THEN** system executes the OpenSpec CLI

#### Scenario: OpenSpec version check
- **WHEN** user runs 'openspec --version'
- **THEN** system displays installed OpenSpec version

### Requirement: Project initialization
The system SHALL support initializing OpenSpec in projects.

#### Scenario: Initialize OpenSpec structure
- **WHEN** user runs 'openspec init' in project directory
- **THEN** system creates openspec directory with project.md and AGENTS.md

#### Scenario: AI tool selection during init
- **WHEN** user initializes OpenSpec
- **THEN** system prompts for AI tool selection and configures accordingly

### Requirement: Change creation
The system SHALL allow creating new OpenSpec changes with workflow schemas.

#### Scenario: Create new change
- **WHEN** user runs 'openspec new change <name>'
- **THEN** system creates change directory with scaffolded artifact structure

#### Scenario: Default schema
- **WHEN** user creates change without specifying schema
- **THEN** system uses spec-driven workflow schema

#### Scenario: Custom schema selection
- **WHEN** user runs 'openspec new change <name> --schema <schema>'
- **THEN** system creates change with specified workflow schema

### Requirement: Change status tracking
The system SHALL provide visibility into change progress and artifact completion.

#### Scenario: View change status
- **WHEN** user runs 'openspec status --change <name>'
- **THEN** system displays artifact completion status and dependencies

#### Scenario: JSON status output
- **WHEN** user runs 'openspec status --change <name> --json'
- **THEN** system outputs structured JSON status information

### Requirement: Artifact instructions
The system SHALL provide contextual instructions for creating each artifact.

#### Scenario: Get artifact instructions
- **WHEN** user runs 'openspec instructions <artifact> --change <name>'
- **THEN** system displays template, context, and guidance for artifact

#### Scenario: JSON instructions output
- **WHEN** user runs 'openspec instructions <artifact> --change <name> --json'
- **THEN** system outputs structured JSON with all instruction fields

### Requirement: Change listing
The system SHALL allow listing all changes in a project.

#### Scenario: List changes
- **WHEN** user runs 'openspec list'
- **THEN** system displays all changes with status information

#### Scenario: JSON list output
- **WHEN** user runs 'openspec list --json'
- **THEN** system outputs structured JSON with change details and timestamps

### Requirement: Schema management
The system SHALL support viewing and managing workflow schemas.

#### Scenario: List available schemas
- **WHEN** user runs 'openspec schemas'
- **THEN** system displays all available workflow schemas

#### Scenario: JSON schema output
- **WHEN** user runs 'openspec schemas --json'
- **THEN** system outputs structured JSON schema definitions

### Requirement: Change archiving
The system SHALL support archiving completed changes to main specs.

#### Scenario: Archive change
- **WHEN** user runs 'openspec archive --change <name>'
- **THEN** system moves spec files to openspec/specs/ and archives change directory

#### Scenario: Delta spec merging
- **WHEN** archiving change with modified capabilities
- **THEN** system merges delta specs into existing spec files

### Requirement: Spec-driven workflow support
The system SHALL implement the spec-driven workflow with proposal, design, specs, and tasks artifacts.

#### Scenario: Proposal artifact
- **WHEN** change uses spec-driven schema
- **THEN** system requires proposal.md as first artifact

#### Scenario: Design and specs parallel creation
- **WHEN** proposal is complete
- **THEN** system allows creating both design.md and specs in parallel

#### Scenario: Tasks dependency
- **WHEN** design and specs are complete
- **THEN** system unlocks tasks.md creation

### Requirement: AI agent integration
The system SHALL provide guidelines and context suitable for AI agent consumption.

#### Scenario: AGENTS.md generation
- **WHEN** OpenSpec is initialized
- **THEN** system creates AGENTS.md with AI-readable instructions

#### Scenario: Project context in project.md
- **WHEN** OpenSpec is initialized
- **THEN** system creates project.md template for project background

#### Scenario: Structured output formats
- **WHEN** AI agent requests information with --json flag
- **THEN** system provides machine-parseable JSON output

### Requirement: Multi-change support
The system SHALL support managing multiple concurrent changes in a project.

#### Scenario: Multiple active changes
- **WHEN** multiple changes exist in openspec/changes/
- **THEN** system tracks each change independently

#### Scenario: Change isolation
- **WHEN** working on one change
- **THEN** system keeps artifacts separate from other changes

### Requirement: Validation and error handling
The system SHALL validate artifact structure and dependencies.

#### Scenario: Missing dependencies
- **WHEN** artifact depends on incomplete prerequisites
- **THEN** system blocks artifact creation and reports missing dependencies

#### Scenario: Invalid artifact structure
- **WHEN** artifact file has incorrect format
- **THEN** system provides validation errors with specific issues
