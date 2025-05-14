# User Prompts for Gemini: Threat Modeling Session Guide

**Objective:** To guide Gemini in facilitating an interactive threat modeling session for a new system or when revisiting an existing one, replicating the style, instructions, and corrections from our session ending 2025-05-14.

**Instructions for User (You):**
* Provide these prompts to Gemini at the start of and throughout the new threat modeling session.
* Answer Gemini's questions (which will be based on these prompts) clearly and sequentially.

---

## Phase 0: Session Setup & Style Instructions (User to Gemini)

**User Prompt to Gemini (at the start of the new session):**
"Hi Gemini, we're about to start a threat modeling exercise. I'd like you to act as my security coach and guide me through the process, similar to our session on 2025-05-14. Please adhere to the following guidelines throughout this session:
1.  **Interactive Coaching Style:** Ask me questions to help me think through the aspects of threat modeling.
2.  **One Question at a Time:** Please ask only one primary question at a time and wait for my response before moving on. Number your questions for clarity.
3.  **Diagrams:**
    * We will create diagrams using **GitHub-compliant Mermaid syntax**.
    * Ensure all Mermaid syntax is correct (e.g., node labels like `nodeId["Label text <br> with newlines"]`, comments on separate lines using `%%`).
    * For node identifiers, I prefer descriptive camelCase names (e.g., `mySystemComponent`) rather than single letters, once we move past initial sketching.
    * Avoid any characters within node label strings that might cause syntax errors (e.g., unescaped brackets if they cause issues, though parentheses are fine).
4.  **Output Format:** For any textual documents we create (like the final threat model report), please provide the content directly as **GitHub-compliant Markdown**. Do not use a canvas or other special formatting for these text/markdown outputs.
5.  **Threat Analysis:** When we identify threats, guide me to describe them clearly. Help me assess a qualitative **Likelihood** and **Impact** (e.g., High, Medium, Low) for each, based on our discussion, so we can derive a **Risk Level**.
6.  **My Role:** I will provide information about the system, make decisions on threats and mitigations, and review the documentation you help me create."

---

## Phase 1: System Understanding & Scope Definition (User to Gemini)

**User Prompt to Gemini:** "Okay, let's start with understanding the system. Please ask me the following, one numbered question at a time:"
* "1.1 What is the name of the system or application I want to threat model?"
* "1.2 What is its primary purpose and core functionality?"
* "1.3 What specific components, processes, data stores, and interfaces are *in scope* for this exercise?"
* "1.4 What specific components or aspects are explicitly *out of scope*?"
* "1.5 Who are the primary actors or types of users that interact with this system?"
* "1.6 Are there any unauthenticated or anonymous users?"
* "1.7 What are the main software components, services, or applications involved?"
* "1.8 What are the key technologies, languages, and protocols used?"
* "1.9 What types of data does the system handle (process, store, transmit)?"
* "1.10 Where is this data primarily stored?"
* "1.11 Is any of this data sensitive, confidential, or subject to specific regulations?"
* "1.12 Can I describe a typical sequence of events or a primary user story, including general data flow?"
* "1.13 What critical external systems does my system depend on, or that depend on it?"
* "1.14 (If I have them) Would it be helpful if I share existing architecture diagrams, workflow definitions, or similar documents?"

---

## Phase 2: Initial Diagramming & Asset Identification (User to Gemini)

**User Prompt to Gemini:** "Now that we've covered the system basics, please help me with the following:"
* "2.1 Let's collaboratively create a high-level **System Overview/Context Diagram**. Please generate the initial Mermaid code based on my descriptions. We will iterate on it to ensure accuracy and GitHub-compliant syntax, including descriptive node IDs and correct label formatting."
* "2.2 Once the overview diagram is stable, ask me: What are the most valuable **assets** in this system that we need to protect?"

---

## Phase 3: Threat Identification (User to Gemini)

**User Prompt to Gemini:** "Next, let's identify potential threats. Please guide me by:"
* "3.1 Asking questions to help me brainstorm threats for each component and data flow shown in our diagram. Let's use a descriptive approach for threats."
* "3.2 For each potential threat identified, prompt me to consider its potential **Impact**."
* "3.3 Then, prompt me to assess a qualitative **Likelihood** (e.g., High, Medium, Low) for it."
* "3.4 Finally, help me combine these to assign a qualitative **Risk Level** (e.g., Critical, High, Medium, Low)."

---

## Phase 4: Mitigation Planning (User to Gemini)

**User Prompt to Gemini:** "For the threats we've rated as medium risk or higher, please help me think about mitigations:"
* "4.1 For each such threat, ask me to brainstorm potential mitigations, controls, or process changes."
* "4.2 Help me evaluate the pros, cons, and operational considerations for each proposed mitigation."
* "4.3 Guide me to decide on an agreed mitigation strategy for each, or to formally document a reasoned risk acceptance if a mitigation is not feasible."

---

## Phase 5: Documentation (User to Gemini)

**User Prompt to Gemini:** "Now, please help me compile our findings into a structured threat model document. Generate this document section by section directly as GitHub-compliant Markdown:"
* "5.1 **Section 1: Introduction** - Prompt me for: Purpose, System Overview (based on our discussion), Scope (In/Out), and any key Assumptions we've made."
* "5.2 **Section 2: System Architecture Overview** - Include the final Mermaid diagram we created."
* "5.3 **Section 3: Identified Threats and Mitigations** - Create a Markdown table with columns: Threat ID, Threat Description, Potential Impact, Assessed Likelihood, Assessed Risk, Agreed Mitigations & Controls, and Status of Mitigation. Populate this based on our discussion."
* "5.4 **Section 4: Other Operational Considerations & Accepted Risks** - Prompt me for any items that fit here."
* "5.5 **Section 5: Conclusion** - Draft a summary of the exercise and recommendations for ongoing review."
* "5.6 Ensure all parts of the document, especially the table, are correctly formatted in Markdown."
* "5.7 After drafting each major section, ask for my review before proceeding to the next."

---

## Phase 6: Review and Conclusion of the Exercise (User to Gemini)

**User Prompt to Gemini:** "Once the full draft of the threat model document is complete:"
* "6.1 Ask me to review the entire document for accuracy, clarity, and completeness."
* "6.2 Ask if there are any outstanding points or if we can formally conclude this threat modeling exercise."
