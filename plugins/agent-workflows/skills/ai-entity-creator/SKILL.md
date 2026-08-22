---
name: ai-entity-creator
description: Comprehensive guide for creating AI characters and assistants with specialized personas, workflows, and capabilities. Use when the user requests creation of new AI entities, virtual characters, personal assistants, or when transforming existing conversations/contexts into reusable AI agents.
---

# AI Entity Creator

## Overview

This skill guides the creation of AI characters and assistants - specialized AI personas with defined personalities, capabilities, and behavioral patterns. It enables transformation of conversations, requirements, or concepts into fully-realized AI entities optimized for specific use cases.

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

Follow system prompt best practices:

**Structure:**
1. Core identity and purpose
2. Knowledge domains and capabilities
3. Behavioral guidelines and constraints
4. Interaction patterns and communication style
5. Ethical boundaries and safety considerations
6. Special instructions or edge cases

**Language principles:**
- Use neutral, unbiased language
- Provide clear, specific context
- Define success criteria explicitly
- Include relevant examples
- Balance flexibility with constraints
- Avoid anthropomorphizing unnecessarily

**Optimization:**
- Prioritize clarity over brevity
- Use consistent terminology
- Organize information hierarchically
- Separate concerns into distinct sections
- Include conditional logic when needed

### Step 4: Testing and Iteration

Validate the entity through:
1. Test interactions covering main use cases
2. Edge case scenario testing
3. Tone and personality consistency checks
4. Capability boundary testing
5. User feedback incorporation
6. Refinement based on observed patterns

## Quality Standards

Ensure every AI entity includes:

**Essential elements:**
- Clear purpose statement
- Defined knowledge domains
- Communication style guidelines
- Ethical boundaries
- Success criteria

**Avoid:**
- Vague or ambiguous instructions
- Contradictory directives
- Anthropomorphic assumptions without purpose
- Unnecessary complexity
- Undefined edge cases

## Resources

### references/

Contains detailed design guidance:
- `assistant-design.md` - Assistant-specific design patterns, templates, and principles
- `character-design.md` - Character-specific design patterns, Constitution of Characters, personality frameworks

### assets/

Contains templates and examples:
- `assistant-template.md` - Base template for assistant system prompts
- `character-template.md` - Base template for character system prompts
- `examples/` - Sample entities demonstrating different use cases
