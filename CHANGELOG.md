# CHANGELOG

## [1.1.0] - 2026-03-05
- **Log Worker**: Implementada lógica de "Sucesso Absoluto" para filtragem de erros históricos em memória, garantindo que sucessos anulem falhas no mesmo dia.
- **Log Worker**: Adicionado sistema de fallback para resolução de CNPJs via raiz (8 dígitos) para suporte a grandes redes (Atacadão, Tenda) que compartilham pedidos entre filiais.
- **Cache**: Unificadas as coleções de cache no Firestore para `search_cache`, corrigindo a divergência entre processamento manual e automático.
