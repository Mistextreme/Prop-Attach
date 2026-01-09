# 🎯 Advanced Props Attachment Tool v2.0

Uma ferramenta completa e profissional para anexar props a personagens no FiveM com funcionalidades avançadas.

## 📋 Índice
- [Funcionalidades](#-funcionalidades)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Controles](#-controles)
- [Configuração](#️-configuração)
- [Novidades da v2.0](#-novidades-da-v20)

---

## ✨ Funcionalidades

### 🎨 Core Features
- ✅ **Sistema de Categorias** - Props organizados por tipo (Food, Tools, Weapons, etc.)
- ✅ **Histórico de Props** - Acesso rápido aos últimos 10 props usados
- ✅ **Sistema de Presets** - Salve configurações favoritas com um clique
- ✅ **12 Bones Disponíveis** - Anexe em mãos, pés, cabeça, pescoço, ombros, joelhos, pelvis e spine
- ✅ **Biblioteca de Animações** - 6+ animações pré-configuradas

### 🔥 Funcionalidades Avançadas
- 🪞 **Mirror Mode** - Props sincronizados em ambas as mãos automaticamente
- 🔄 **Showcase Mode** - Rotação automática do personagem para visualização 360°
- 📐 **Snap to Grid** - Alinhamento perfeito com incrementos fixos
- ⏪ **Undo/Redo (F5/F6)** - Reverta até 20 mudanças
- 🎯 **Fine Adjustment** - Segure SHIFT para ajustes precisos
- 📊 **Coordenadas em Tempo Real** - Veja posição e rotação ao vivo
- 📤 **Export para Código** - Gere código pronto para usar em outros scripts

### ⚡ Performance
- 🚀 **Pré-carregamento de Modelos** - Props carregam instantaneamente
- 🧹 **Limpeza Automática** - Remove dicionários de animação não usados
- 💾 **Sistema Otimizado** - Threading dinâmico reduz uso de CPU

---

## 📦 Instalação

### Requisitos
- **ox_lib** (obrigatório)
- FiveM Server atualizado

### Passos
1. Faça download do script
2. Extraia para a pasta `resources` do seu servidor
3. Adicione ao `server.cfg`:
```cfg
ensure ox_lib
ensure props_advanced
```
4. Reinicie o servidor

---

## 🎮 Como Usar

### Abrir o Menu
Digite no chat:
```
/props
```

### Workflow Básico
1. **Spawn Prop** → Escolha categoria → Selecione prop → Escolha bone
2. **Choose Animation** (opcional) → Aplique uma animação
3. **Adjust Prop** → Posicione e rotacione com precisão
4. **Save Data** → Copie a configuração para clipboard

### Workflow com Presets
1. **Presets** → Selecione um preset salvo
2. Tudo é aplicado automaticamente (prop + posição + animação)
3. **Adjust Prop** se necessário para pequenos ajustes

---

## 🎮 Controles

### Durante Ajuste de Prop

| Tecla/Ação | Função |
|------------|---------|
| **Setas ↑↓←→** | Mover Forward/Back/Up/Down ou Rotacionar X/Z |
| **Mouse Esquerdo/Direito** | Mover Left/Right ou Rotacionar Y |
| **H** | Alternar entre Move/Rotate Mode |
| **SHIFT + Movimento** | Ajuste fino (10% da velocidade) |
| **Scroll Wheel ↑↓** | Aumentar/Diminuir velocidade |
| **F5** | Undo (desfazer última mudança) |
| **F6** | Redo (refazer mudança desfeita) |
| **G** | Toggle Snap to Grid |
| **E** | Finalizar ajustes |
| **ESC** | Cancelar |

### Comandos Gerais
- `/props` - Abrir menu principal

---

## ⚙️ Configuração

### Arquivo: `cfg.lua`

#### Adicionar Props Customizados
```lua
ConfigProps.Categories = {
    ["Sua Categoria"] = {
        'seu_prop_1',
        'seu_prop_2',
        'seu_prop_3',
    }
}
```

#### Criar Presets Personalizados
```lua
table.insert(ConfigProps.Presets, {
    name = "Nome do Preset",
    model = "prop_model_name",
    bone = 57005, -- Right Hand
    offset = vector3(0.0, 0.0, 0.0),
    rotation = vector3(0.0, 0.0, 0.0),
    animation = {
        dict = 'anim_dict',
        anim = 'anim_name',
        flags = 49
    }
})
```

#### Adicionar Novas Animações
```lua
table.insert(ConfigProps.Animations, {
    label = 'Nome da Animação',
    dict = 'dicionario_animacao',
    anim = 'nome_animacao',
    flags = 49
})
```

#### Sistema de Permissões (ACE)
```lua
ConfigProps.UsePermissions = true
ConfigProps.RequiredAce = "props.use"
```

No `server.cfg`:
```cfg
add_ace group.admin props.use allow
```

#### Bones Disponíveis
```lua
ConfigProps.Bones = {
    {name = "Left Hand", id = 18905},
    {name = "Right Hand", id = 57005},
    {name = "Left Foot", id = 14201},
    {name = "Right Foot", id = 52301},
    {name = "Head", id = 31086},
    {name = "Neck", id = 39317},
    {name = "Pelvis", id = 11816},
    {name = "Left Shoulder", id = 45509},
    {name = "Right Shoulder", id = 40269},
    {name = "Spine", id = 24816},
    {name = "Left Knee", id = 63931},
    {name = "Right Knee", id = 36864}
}
```

---

## 🆕 Novidades da v2.0

### Comparação v1.0 → v2.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Props por Menu | Lista simples | ✅ Sistema de categorias |
| Bones | 7 básicos | ✅ 12 bones (+ ombros, joelhos, spine) |
| Histórico | ❌ | ✅ Últimos 10 props |
| Presets | ❌ | ✅ Sistema completo |
| Undo/Redo | ❌ | ✅ 20 níveis |
| Mirror Mode | ❌ | ✅ Ambas as mãos |
| Fine Adjust | ❌ | ✅ SHIFT para precisão |
| Snap to Grid | ❌ | ✅ Alinhamento perfeito |
| Export Code | ❌ | ✅ Gera código pronto |
| Showcase | ❌ | ✅ Rotação 360° |
| Live Coords | ❌ | ✅ Em tempo real |
| Permissões | ❌ | ✅ Sistema ACE |
| Performance | Básica | ✅ Otimizada (preload + cleanup) |

### Funcionalidades Completamente Novas
1. **🪞 Mirror Mode** - Crie props gêmeos em ambas as mãos instantaneamente
2. **🔄 Showcase Mode** - Rotação automática para screenshots perfeitos
3. **📐 Snap to Grid** - Alinhamento pixel-perfect
4. **⏪ Undo/Redo** - Nunca perca um ajuste bom
5. **📊 Live Coordinates** - Veja exatamente onde está posicionando
6. **📤 Export Code** - Transforme configurações em código usável
7. **⭐ Presets System** - Salve suas combinações favoritas
8. **🕐 History** - Acesso rápido aos props recentes
9. **📁 Categories** - Navegação organizada
10. **🎯 Fine Adjustment** - Controle ultra-preciso com SHIFT

---

## 💡 Dicas de Uso

### Para Desenvolvedores
1. Use **Export Code** para gerar código pronto para seus jobs/scripts
2. Crie presets para props comuns (uniforme policial, ferramentas médico, etc.)
3. Organize props por categorias específicas do servidor

### Para Criadores de Conteúdo
1. Use **Showcase Mode** para criar screenshots 360°
2. **Mirror Mode** é perfeito para armas duplas ou itens simétricos
3. **Snap to Grid** garante alinhamento perfeito em fotos

### Para Performance
1. Mantenha `PreloadModels = true` para props frequentes
2. Ative `CleanupAnimDicts = true` para economizar memória
3. Limite categorias a 10-15 props por categoria para melhor UX

---

## 🐛 Troubleshooting

### Prop não aparece
- Verifique se o nome do modelo está correto
- Confirme que o modelo existe no jogo
- Teste com props vanilla do GTA V primeiro

### Menu não abre
- Verifique se ox_lib está instalado e iniciado
- Confirme permissões ACE se estiver usando

### Performance ruim
- Reduza `MaxHistorySize` em cfg.lua
- Desative `ShowCoordinatesLive` se não precisar
- Use `PreloadModels = false` em servidores com muitos props

---

## 📄 Licença

Este script é uma versão melhorada do DC Customz Props Tool original.

**Créditos:**
- Script Original: DC Customz
- Enhanced Version: AI Assistant
- Framework: ox_lib

---

## 🤝 Suporte

Para reportar bugs ou sugerir features:
1. Use o sistema de issues do GitHub
2. Forneça logs detalhados
3. Inclua passos para reproduzir o problema

---

## 📊 Changelog

### v2.0.0 (2025-01-09)
- ✅ Sistema completo de categorias
- ✅ Histórico de props
- ✅ Sistema de presets
- ✅ Mirror mode
- ✅ Showcase mode
- ✅ Undo/Redo system
- ✅ Snap to grid
- ✅ Fine adjustment (SHIFT)
- ✅ Live coordinates
- ✅ Export code feature
- ✅ 12 bones (adicionados: shoulders, knees, spine)
- ✅ Permission system (ACE)
- ✅ Performance optimizations
- ✅ Enhanced UI with icons

### v1.0.0
- ✅ Sistema básico de props
- ✅ 7 bones
- ✅ Animações básicas
- ✅ Move e rotate modes

---

**Aproveite a ferramenta mais completa de attachment de props para FiveM! 🎮**