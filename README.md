# PesoTrack — Acompanhamento Inteligente de Peso

> Aplicativo Flutter mobile-first para acompanhamento de peso, com onboarding, metas, dashboard, histórico, gráficos de evolução e calculadora de IMC. O projeto já possui base para OCR e integrações futuras.

---

## Sumário

- [Visão Geral](#visão-geral)
- [Regras de Negócio](#regras-de-negócio)
- [Requisitos Funcionais](#requisitos-funcionais)
- [Requisitos Não Funcionais](#requisitos-não-funcionais)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Dependências](#dependências)
- [Fluxo de Telas](#fluxo-de-telas)
- [Arquitetura](#arquitetura)
- [Como Rodar](#como-rodar)
- [Roadmap](#roadmap)

---

## Visão Geral

O **PesoTrack** é um aplicativo Android/iOS desenvolvido em Flutter para acompanhamento contínuo de peso corporal. A experiência atual prioriza cadastro inicial, definição de metas, registro manual, histórico, indicadores visuais e cálculo de IMC em uma interface mobile-first.

No estado atual do projeto, o fluxo principal entregue contempla:
- onboarding e configuração inicial do perfil
- dashboard com resumo da evolução
- registro manual de peso
- histórico de registros
- calculadora de IMC
- gestão de metas no perfil

O repositório também já possui estrutura técnica para evolução com OCR, notificações, exportação e integrações externas.

**Personas:**
- **Usuário final** — pessoa que quer monitorar o próprio peso com mínimo esforço
- **Profissional de saúde** — acompanha a evolução do usuário a partir dos registros e relatórios do app

---

## Regras de Negócio

### RN-01 · Cadastro único de perfil
O usuário preenche nome, peso inicial, altura, sexo biológico e data de nascimento **somente na primeira abertura do app** (onboarding). Após salvo, esses dados podem ser editados somente na tela de Perfil.

### RN-02 · Frequência de registro
Apenas **um registro por dia** é permitido. Caso o usuário tente registrar novamente no mesmo dia, o sistema apresenta a opção de **sobrescrever** o registro existente, com confirmação explícita.

### RN-03 · Validação de peso
O peso informado deve estar entre **20 kg e 300 kg**, com precisão de até **uma casa decimal**. Valores fora desse intervalo são rejeitados com mensagem de erro inline.

### RN-04 · OCR — extração de peso
Ao capturar uma foto da balança:
1. O app extrai o maior número encontrado na imagem via Google ML Kit (offline).
2. Se o número extraído estiver **fora do intervalo 20–300 kg**, o sistema descarta a leitura e solicita reenvio.
3. O valor extraído é sempre exibido ao usuário para **confirmação antes de salvar**.
4. O campo fica editável na tela de confirmação, permitindo correção manual.

### RN-05 · Integração com Telegram
- A foto e o peso confirmado são enviados automaticamente ao bot do Telegram após confirmação pelo usuário.
- O envio ao Telegram **não bloqueia** o salvamento local — mesmo sem internet, o registro é gravado no dispositivo.
- Envios pendentes (sem internet) são reenviados automaticamente na próxima conexão.

### RN-06 · Cálculo de IMC
O IMC é calculado pela fórmula padrão da OMS: **IMC = peso(kg) / altura(m)²**.
A classificação segue a tabela OMS, com ajuste para pessoas acima de 65 anos (exibe aviso de que os limiares variam com a idade).
Para o sexo feminino, o peso ideal é calculado pela fórmula de Lorenz ajustada.

### RN-07 · Meta de peso
O usuário pode definir uma meta de peso. O app exibe uma **barra de progresso** indicando a distância entre o peso inicial e a meta. Se o usuário atingir ou ultrapassar a meta, o app exibe uma celebração.

### RN-08 · Exclusão de registro
Registros podem ser excluídos individualmente no histórico. A exclusão é **permanente** e exige confirmação via bottom sheet. Não há lixeira ou desfazer.

### RN-09 · Exportação de dados
O usuário pode exportar todos os registros em formato **CSV** contendo: data, horário, peso, variação, IMC calculado, nota e tipo de entrada (manual/OCR).

### RN-10 · Privacidade
Todos os dados pessoais ficam armazenados **somente no dispositivo** (SQLite local). Nenhum dado é enviado a servidores externos, exceto as fotos/pesos ao bot do Telegram, que é configurado e controlado pelo próprio usuário.

---

## Requisitos Funcionais

### RF-01 · Onboarding
- [ ] Tela de boas-vindas exibida apenas na primeira abertura
- [ ] Formulário com: nome, peso inicial, altura (cm), sexo biológico, data de nascimento, meta de peso
- [ ] Validação de todos os campos antes de avançar
- [ ] Persistência do perfil no dispositivo via `shared_preferences`

### RF-02 · Dashboard / Home
- [ ] Card hero com peso atual, data/hora do último registro e barra de progresso rumo à meta
- [ ] KPIs: Peso Atual, Variação Total, IMC, Streak (dias consecutivos com registro)
- [ ] Gráfico de linha com evolução dos últimos 30 dias (fl_chart)
- [ ] Lista dos 3 últimos registros com variação colorida
- [ ] Botão de acesso rápido para registrar peso

### RF-03 · Registro Manual
- [ ] Formulário com campo de peso, data, horário e nota opcional
- [ ] Data pré-preenchida com o dia atual
- [ ] Validação de peso (20–300 kg, 1 casa decimal)
- [ ] Regra de um registro por dia (RN-02)

### RF-04 · OCR via Câmera / Galeria
- [ ] Abertura de câmera ou galeria via `image_picker`
- [ ] Extração de texto numérico via `google_mlkit_text_recognition`
- [ ] Animação de "scan" enquanto processa
- [ ] Tela de confirmação com peso detectado e campo editável
- [ ] Integração do fluxo OCR com o registro principal do aplicativo

### RF-05 · Histórico
- [ ] Lista paginada de todos os registros, ordem decrescente por data
- [ ] Cada item exibe: data, peso, variação, IMC calculado, tipo (manual/OCR), nota, badge de origem
- [ ] Swipe to delete com confirmação
- [ ] Filtro por período (7 dias, 30 dias, 3 meses, tudo)
- [ ] Exportação CSV (RN-09)

### RF-06 · Calculadora de IMC
- [ ] Inputs: peso, altura, sexo, idade
- [ ] Pré-preenchimento com dados do perfil e último registro
- [ ] Barra visual indicando posição na escala OMS
- [ ] Classificação com indicador visual (cores e rótulos)
- [ ] Cálculo de peso ideal estimado por sexo
- [ ] Aviso para pessoas acima de 65 anos

### RF-07 · Perfil
- [ ] Exibição e edição dos dados cadastrados no onboarding
- [ ] Campo para configurar token do bot Telegram e chat ID
- [ ] Opção de limpar todos os dados (com confirmação dupla)

### RF-08 · Notificações
- [ ] Notificação local diária no horário configurado pelo usuário lembrando de registrar o peso
- [ ] Notificação de celebração ao atingir a meta

### RF-09 · Tema
- [ ] Suporte a tema claro (Estilo C — Soft Wellness) e escuro
- [ ] Alternância manual pelo usuário

---

## Requisitos Não Funcionais

### RNF-01 · Performance
- O app deve carregar a tela inicial em **menos de 2 segundos** em dispositivos com 2 GB de RAM.
- O OCR deve processar a imagem em **menos de 3 segundos** em condições normais.
- Operações de banco de dados devem ser executadas em **background thread** (Isolate ou async/await).

### RNF-02 · Usabilidade
- Layout **mobile-first**, otimizado para telas entre 360dp e 430dp de largura.
- Todos os elementos interativos devem ter área mínima de toque de **48×48dp** (guideline Material 3).
- Feedback visual imediato para toda ação do usuário (loading states, toasts, animações).
- App acessível: contraste mínimo **4.5:1** entre texto e fundo (WCAG AA).

### RNF-03 · Confiabilidade
- Dados locais persistem mesmo após **fechamento forçado** do app.
- Falha na conexão com o Telegram não causa perda de dados locais.
- Rollback de transação em caso de erro ao salvar no banco de dados.

### RNF-04 · Segurança
- Nenhuma informação pessoal é transmitida a servidores de terceiros sem consentimento explícito.
- Token do Telegram armazenado com `flutter_secure_storage`, nunca em texto plano.
- Permissões de câmera e armazenamento solicitadas somente quando necessárias.

### RNF-05 · Manutenibilidade
- Arquitetura em camadas: `presentation` / `domain` / `data`.
- Cobertura mínima de testes unitários: **70%** nos serviços e modelos.
- Código comentado em português para funções de negócio críticas.

### RNF-06 · Compatibilidade
- Android: **API 24+** (Android 7.0 Nougat ou superior)
- iOS: **iOS 14+**
- Flutter: versão **3.22+** / Dart **3.4+**

### RNF-07 · Offline First
- Todas as funcionalidades principais (registro, histórico, IMC, gráfico) funcionam **100% offline**.
- Sincronização com Telegram ocorre quando há conexão disponível.

---

## Estrutura do Projeto

```
pesotrack/
│
├── android/                        # Configurações nativas Android
├── ios/                            # Configurações nativas iOS
├── assets/
│   ├── icons/                      # Ícones base e assets para launcher
│   └── fonts/                      # Plus Jakarta Sans (display), Inter (body)
│
├── lib/
│   ├── main.dart                   # Entrada da aplicação
│   │
│   ├── app/
│   │   ├── app.dart                # MaterialApp, AppGate e rotas
│   │   ├── app_shell.dart          # Scaffold principal com NavigationBar
│   │   └── routes.dart             # Rotas nomeadas da aplicação
│   │
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData claro e escuro
│   │   ├── app_colors.dart         # Paleta de cores
│   │   ├── app_gradients.dart      # Gradientes da interface
│   │   ├── app_radii.dart          # Raios e cantos padronizados
│   │   ├── app_shadows.dart        # Sombras reutilizáveis
│   │   ├── app_spacing.dart        # Escala de espaçamento
│   │   └── app_text_styles.dart    # Tipografia reutilizável
│   │
│   ├── models/
│   │   ├── weight_entry.dart       # Modelo de registro de peso
│   │   ├── user_profile.dart       # Perfil do usuário e metas
│   │   └── imc_result.dart         # Modelo de resultado do IMC
│   │
│   ├── services/
│   │   ├── database_service.dart   # SQLite: CRUD de registros
│   │   ├── export_service.dart     # Exportação de dados
│   │   ├── notification_service.dart # Notificações locais
│   │   ├── ocr_service.dart        # OCR com Google ML Kit
│   │   ├── profile_service.dart    # Persistência do perfil
│   │   ├── telegram_service.dart   # Integrações externas futuras
│   │   └── weight_entries_service.dart # Regras de acesso aos registros
│   │
│   ├── providers/                  # Gerenciamento de estado com Riverpod
│   │   ├── weight_provider.dart    # Estado dos registros de peso
│   │   ├── profile_provider.dart   # Estado do perfil do usuário
│   │   └── theme_provider.dart     # Estado do tema (claro/escuro)
│   │
│   ├── pages/
│   │   ├── onboarding/
│   │   │   ├── onboarding_page.dart       # Tela de boas-vindas
│   │   │   └── profile_setup_page.dart    # Formulário de cadastro inicial
│   │   │
│   │   ├── home/
│   │   │   ├── home_page.dart             # Dashboard principal
│   │   │   └── widgets/
│   │   │       ├── hero_weight_card.dart  # Card hero com peso e progresso
│   │   │       ├── kpi_grid.dart          # Grade com 4 KPIs
│   │   │       ├── weight_chart.dart      # Gráfico de linha (fl_chart)
│   │   │       └── recent_entries_list.dart # 3 últimos registros
│   │   │
│   │   ├── add_weight/
│   │   │   ├── add_weight_page.dart       # Registro manual
│   │   │   └── widgets/
│   │   │       ├── manual_weight_form.dart # Formulário principal de registro
│   │   │       └── weight_form.dart        # Componentes auxiliares de formulário
│   │   │
│   │   ├── ocr/
│   │   │   ├── ocr_page.dart              # Fluxo OCR disponível para integração
│   │   │   └── widgets/
│   │   │       ├── upload_zone.dart       # Área de upload com animação
│   │   │       ├── scan_animation.dart    # Animação da linha de scan
│   │   │       └── ocr_confirm_sheet.dart # Bottom sheet de confirmação
│   │   │
│   │   ├── history/
│   │   │   ├── history_page.dart          # Histórico completo
│   │   │   └── widgets/
│   │   │       ├── history_filter_bar.dart # Filtro por período
│   │   │       └── history_tile.dart       # Item do histórico
│   │   │
│   │   ├── imc/
│   │   │   ├── imc_page.dart              # Calculadora de IMC
│   │   │   └── widgets/
│   │   │       ├── imc_bar.dart           # Barra visual da escala OMS
│   │   │       └── imc_result_card.dart   # Card de resultado colorido
│   │   │
│   │   └── profile/
│   │       ├── profile_page.dart          # Perfil e configurações
│   │       └── widgets/
│   │           └── telegram_config_card.dart # Configuração do bot Telegram
│   │
│   ├── widgets/                    # Widgets globais reutilizáveis
│   │   ├── soft_card.dart          # Card com borda e sombra do Estilo C
│   │   ├── soft_button.dart        # Botão primário e secundário
│   │   ├── soft_text_field.dart    # Campo de texto estilizado
│   │   ├── section_header.dart     # Cabeçalho de seção
│   │   ├── kpi_card.dart           # Card de KPI individual
│   │   ├── delta_badge.dart        # Badge de variação (+ / -)
│   │   ├── app_toast.dart          # Feedback toast inline
│   │   └── empty_state.dart        # Estado vazio com ilustração
│   │
│   └── utils/
│       ├── date_formatter.dart     # Formatação de datas em pt-BR
│       ├── weight_validator.dart   # Validações de peso (RN-03)
│       ├── imc_calculator.dart     # Lógica de IMC e classificação OMS
│       └── extensions.dart         # Extensions de String, DateTime, double
│
├── test/
│   ├── models/
│   │   └── weight_entry_test.dart
│   ├── services/
│   │   ├── database_service_test.dart
│   │   ├── ocr_service_test.dart
│   │   └── telegram_service_test.dart
│   └── utils/
│       ├── weight_validator_test.dart
│       └── imc_calculator_test.dart
│
├── pubspec.yaml
└── README.md
```

---

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Estado
  flutter_riverpod: ^2.5.1

  # Banco de dados local
  sqflite: ^2.3.3
  path: ^1.9.0

  # Preferências / segurança
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0

  # OCR offline
  google_mlkit_text_recognition: ^0.13.1

  # Câmera e galeria
  image_picker: ^1.1.2
  camera: ^0.11.0+2

  # Gráficos
  fl_chart: ^0.68.0

  # Requisições HTTP (Telegram)
  http: ^1.2.1
  connectivity_plus: ^6.0.5

  # Notificações locais
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4

  # Permissões
  permission_handler: ^11.3.1

  # UI auxiliares
  intl: ^0.20.2
  share_plus: ^9.0.0
  image: ^4.5.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
  flutter_launcher_icons: ^0.14.3
```

---

## Fluxo de Telas

```mermaid
flowchart TD
  A[Abertura do app] --> G{Perfil existente?}
  G -->|Não| O[Onboarding]
  O --> P[Configuração inicial do perfil]
  P --> S[AppShell]
  G -->|Sim| S

  S --> H[Início]
  S --> R[Registro]
  S --> HI[Histórico]
  S --> I[IMC]
  S --> PR[Perfil]

  R --> RM[Registro manual]
  RM --> H
  RM --> HI

  PR --> MG[Criar ou encerrar meta]
  MG --> H
```

Fluxo complementar disponível no código, mas fora da navegação principal atual:

```text
OcrPage -> confirmação de leitura -> salvamento como entrada OCR
```

---

## Arquitetura

O app segue uma arquitetura em **3 camadas** baseada em Clean Architecture simplificada:

```
┌─────────────────────────────────────────┐
│           PRESENTATION (UI)             │
│  pages/ + widgets/ + theme/             │
│  Consome providers, exibe estado        │
├─────────────────────────────────────────┤
│              DOMAIN (Negócio)           │
│  models/ + utils/ + providers/          │
│  Regras de negócio puras, sem Flutter   │
├─────────────────────────────────────────┤
│               DATA (Acesso)             │
│  services/                              │
│  SQLite, SharedPrefs, ML Kit, HTTP      │
└─────────────────────────────────────────┘
```

**Gerenciamento de estado:** Riverpod (`StateNotifierProvider` para listas, `FutureProvider` para perfil)

---

## Como Rodar

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar em modo debug (Android)
flutter run

# 3. Gerar APK de release
flutter build apk --release

# 4. Rodar testes
flutter test

# 5. Analisar código
flutter analyze
```

**Pré-requisitos:**
- Flutter 3.22+ instalado ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android SDK com emulador ou dispositivo físico conectado
- Dart 3.4+

---

## Roadmap

| Versão | Funcionalidade |
|--------|---------------|
| v0.1   | Onboarding e persistência local do perfil |
| v0.2   | Registro manual de peso e histórico local |
| v0.3   | Dashboard com KPIs, gráfico de evolução e IMC |
| v0.4   | Gestão de metas e acompanhamento no perfil |
| v1.0   | Refinamento visual, tema escuro e organização da base |
| v1.1   | Integração do OCR ao fluxo principal de registro |
| v1.2   | Exportação de dados e notificações locais |
| v1.3   | Integração com Telegram e reenvio de pendências |
| v1.4   | Backup e restauração de dados |

---

## Desenvolvido por

Rafael Domingues — Ponta Grossa, PR  
Protótipo visual: **Estilo C · Soft Wellness** (terracota, superfícies quentes, mobile-first)

---

*Documentação atualizada em 5 de maio de 2026.*
