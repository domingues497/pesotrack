---
alwaysApply: true
scene: git_message
---

# Regras para geração de commits Git

Sempre gerar mensagens de commit em português brasileiro
seguindo o padrão Conventional Commits.

## Formato obrigatório

```txt
tipo(escopo): descrição curta
```

## Regras

- usar português brasileiro
- nunca escrever commits em inglês
- usar verbos no imperativo
- primeira linha com no máximo 72 caracteres
- descrição objetiva e técnica
- não usar emojis
- não usar ponto final no título
- escopo opcional

## Tipos permitidos

- feat     → nova funcionalidade
- fix      → correção de bug
- docs     → documentação
- style    → formatação sem alterar lógica
- refactor → refatoração
- test     → testes
- chore    → tarefas gerais
- perf     → performance
- ci       → CI/CD
- build    → build/dependências

## Exemplos válidos

feat(login): adiciona autenticação JWT

fix(api): corrige erro ao buscar usuários

docs(readme): atualiza instruções de instalação

refactor(auth): simplifica validação do token

perf(query): melhora desempenho da consulta Oracle

## Corpo da mensagem

Quando necessário, adicionar corpo explicando:

- POR QUE a alteração foi feita
- COMO foi implementada

Nunca explicar apenas O QUE foi alterado.