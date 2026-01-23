---
name: project-logic-engine
description: Executa análises críticas e frameworks de decisão multicritério. Use para resolver ambiguidades técnicas ou conflitos de arquitetura.
---

# Project Logic Engine (PLE)

## Procedimentos de Raciocínio
1. [cite_start]**Tree of Thoughts (ToT):** Simule três especialistas (Otimista, Pessimista, Pragmático) para avaliar cada decisão crítica[cite: 63, 65].
2. [cite_start]**Chain of Thought (CoT):** Verbalize o raciocínio passo a passo antes da conclusão para reduzir saltos lógicos[cite: 54, 55].
3. [cite_start]**Autocrítica:** Filtre alucinações avaliando a própria lógica antes de gerar o output[cite: 60].

## Estruturação Técnica
- [cite_start]**Entrada:** Utilize tags XML (<requirements>, <code>) para isolar dados de instruções.
- [cite_start]**Saída:** Formate em Markdown hierárquico para leitura humana ou JSON estrito para integração[cite: 83, 90].
- [cite_start]**Ancoragem (Grounding):** Exija evidências textuais ou de código presentes no contexto para cada afirmação[cite: 105].