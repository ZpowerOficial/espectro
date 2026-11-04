# Persistência local e modo temporário

No navegador, avaliações, rascunhos, preferências e biblioteca usam `localStorage`, no namespace `espectro/v2/` da origem atual. Em plataformas nativas, o armazenamento em arquivos continua sendo usado. Não há sincronização entre origens, navegadores ou dispositivos.

A leitura do catálogo embarcado acontece antes da inicialização dos dados pessoais. Um catálogo inválido continua sendo um erro de inicialização; não é substituído por dados vazios.

Se a inicialização dos dados pessoais falhar por indisponibilidade do armazenamento, o aplicativo inicia com o mesmo catálogo em **modo temporário**, usando apenas memória. `AppViewModel.storageNotice` fornece um aviso permanente e explícito para a interface. Avaliações, favoritos, recentes, comparação e preferências dessa sessão desaparecem ao fechar ou recarregar. Os dados duráveis existentes não são apagados, sobrescritos ou migrados para a sessão temporária.

O modo temporário é escolhido na inicialização. Uma falha posterior de escrita da biblioteca é sinalizada por `studyStorageError`; não representa sucesso persistido. O aviso do modo temporário permanece mesmo quando uma operação em memória conclui com sucesso. Para tentar restaurar a persistência durável, é necessário corrigir a permissão ou o espaço disponível e reiniciar o aplicativo. Navegadores também podem remover dados locais por decisão do usuário, modo privado ou política de armazenamento.

Verificação automatizada: `test/data/storage_fallback_test.dart` simula acesso negado, mantém o catálogo acessível, verifica o aviso e confirma que nenhuma gravação/exclusão é feita no armazenamento bloqueado. `test/data/web_storage_browser_test.dart` valida a implementação real de `localStorage` em Chrome.


## Domínio público dos links no app nativo

No navegador, os links usam a origem e a subpasta atuais, com a rota no fragmento. No Android ou desktop, informe a URL pública real da versão web no build, por exemplo: `rtk flutter build apk --dart-define=ESPECTRO_WEB_URL=https://seu-dominio.example/espectro/`. Substitua o endereço pelo deployment existente; essa opção não publica o site nem configura Android App Links.

Somente URLs `http` ou `https` com host e sem credenciais são aceitas. Sem uma URL válida, o aplicativo copia uma rota relativa contendo os dados para reabrir e avisa que um link completo exige a versão web. O compartilhamento de respostas mantém sua confirmação explícita em ambos os casos.
