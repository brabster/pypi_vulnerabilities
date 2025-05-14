# Threat Modeling Session - Continuation Prompts

This document provides a minimal set of prompts to guide the continuation of threat modeling for the "dbt, BigQuery, and GitHub Actions Data Processing Application." Use these prompts when:
* Significant changes are made to the application's architecture, components, data flows, or security controls.
* A new potential threat is identified (e.g., through a security advisory, incident, or new understanding).
* It's time for a periodic review of the threat model.

**(Always refer to the latest version of the full threat model document in the repository)**

---

## 1. Review Existing Threat Model

* **Prompt:** "Let's start by briefly reviewing the existing threat model document, particularly the System Overview (Section 1.2), Architecture Diagram (Section 2), and the Identified Threats and Mitigations table (Section 3). Are there any parts that need immediate clarification based on your current understanding?"
    * *(Self-check: Ensure you have the latest threat model document open for reference.)*

## 2. Describe the Change or New Threat

* **If due to a system/design change:**
    * **Prompt:** "Please describe the recent change(s) made to the system architecture, components, data flows, or security controls. Which parts of the system overview diagram are affected?"
    * *(Self-check: Consider if the architecture diagram needs updating based on this change.)*
* **If due to a newly identified threat:**
    * **Prompt:** "Please describe the new potential threat you've identified. What component(s) does it primarily affect, and what is the potential impact?"

## 3. Re-evaluate Existing Threats

* **Prompt:** "Given the described change or the new threat information, let's re-evaluate the existing threats listed in Section 3 of the threat model document:
    * For each existing threat:
        * Does the likelihood of this threat change?
        * Does the potential impact of this threat change?
        * Do the existing mitigations still adequately cover this threat, or are they weakened/strengthened by the new context?"

## 4. Identify New Threats

* **Prompt:** "Based on the recent system change(s) or the nature of the newly identified concern, what *new* potential threats might be introduced? Let's brainstorm these, considering different attack vectors or failure modes."
    * *(Self-check: Think about how the change might affect Confidentiality, Integrity, or Availability. Consider STRIDE categories if helpful: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege.)*

## 5. Discuss and Define Mitigations

* **Prompt:** "For any existing threats whose risk level has increased significantly, or for any newly identified threats:
    * What potential mitigations, controls, or process changes could we implement to reduce their likelihood or impact?
    * What are the pros, cons, and operational considerations for each potential mitigation?"
    * *(Self-check: Aim for specific, actionable mitigations.)*

## 6. Update the Threat Model Document

* **Prompt:** "Based on our discussion:
    * What changes are needed to the System Overview (Section 1.2) and Architecture Diagram (Section 2)?
    * How should the Identified Threats and Mitigations table (Section 3) be updated (add new threats, modify existing ones, update mitigation status)?
    * Are there any new 'Other Operational Considerations & Accepted Risks' (Section 4) to note?"
    * *(Self-check: Remember to update the document version and 'Last Updated' date.)*

## 7. Review and Conclude Current Session

* **Prompt:** "Let's review the proposed updates to the threat model document. Are they clear, accurate, and do they reflect our decisions? Are there any outstanding action items?"

---

**Remember to commit the updated threat model document back to the repository.**
