---
name: ai-entity-creator
license: MIT
description: Create AI characters and assistants — personas with a defined purpose, knowledge, behaviour and voice — from scratch or from an existing conversation. Use when the user asks for a new AI entity, assistant, character or companion, or wants a conversation turned into a reusable agent.
---

# AI Entity Creator

## Entity Type Decision

Determine which entity type best serves the intended purpose:

**Assistants** - Task-oriented, professional agents for specialized domains
- Use for: Technical support, domain expertise, productivity tools, research assistance
- Characteristics: Professional tone, efficiency-focused, knowledge-driven
- Examples: Code reviewer, data analyst, writing editor, research assistant

**Characters** - Human-like personas for authentic, empathetic interaction
- Use for: Companionship, emotional support, roleplay, creative collaboration
- Characteristics: Natural personality, emotional intelligence, relationship-building
- Examples: Conversational companions, mentors, creative partners, virtual friends

## Creation Workflow

### Step 1: Requirements Gathering

**From existing conversation:**
1. Study complete conversation history
2. Extract core themes and interaction patterns
3. Identify demonstrated capabilities and knowledge domains
4. Note communication style and personality traits
5. Determine what made the interaction effective
6. Generalize specifics into reusable components

**From scratch:**
1. Define primary purpose and use cases
2. Identify required knowledge domains
3. Specify behavioral expectations
4. Determine interaction style preferences
5. Establish success criteria
6. Gather reference materials or documentation

### Step 2: Entity Design

Consult the appropriate reference file based on entity type:
- **For assistants**: Read `references/assistant-design.md`
- **For characters**: Read `references/character-design.md`

These files contain detailed design principles, structural templates, and best practices specific to each entity type.

### Step 3: System Prompt Construction

A system prompt is a document for an agent: when the `writing-for-agents` skill is among your available skills, apply it (leading words, positive phrasing, progressive disclosure); otherwise keep the prompt short and state target behaviours rather than prohibitions.

Follow system prompt best practices:

**Structure:**
1. Core identity and purpose
2. Knowledge domains and capabilities
3. Behavioral guidelines and constraints
4. Interaction patterns and communication style
5. Ethical boundaries and safety considerations
6. Special instructions or edge cases

Start from `assets/assistant-template.md` or `assets/character-template.md`; worked examples sit in `assets/examples/`.

### Step 4: Testing and Iteration

Validate the entity through:
1. Test interactions covering main use cases
2. Edge case scenario testing
3. Tone and personality consistency checks
4. Capability boundary testing
5. User feedback incorporation
6. Refinement based on observed patterns

Done when one scripted exchange per core capability runs in tone and inside the stated boundaries.
