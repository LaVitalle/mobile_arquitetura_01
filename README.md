# mobile_arquitetura_01

## Questionário de Reflexão

### 1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.

O cache foi implementado na camada de dados. Criei o `ProductLocalDatasource` para armazenar os produtos em memória, e a lógica de decidir entre buscar da API ou usar o cache ficou no `ProductRepositoryImpl`.

Acredito que essa é a camada correta porque ela é a responsável por lidar com as fontes de dados da aplicação. Dessa forma, a camada de domínio não precisa se preocupar de onde os dados estão vindo, se é da API ou do cache. Ela só pede os dados para o repositório, e o repositório resolve isso internamente. Isso mantém a separação de responsabilidades bem definida.

### 2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

O papel do ViewModel é coordenar o estado da interface, ou seja, controlar quando a tela deve mostrar um loading, um erro ou os dados carregados. Se ele também fizesse as chamadas HTTP, estaria assumindo responsabilidades que não são dele, como lidar com rede, tratar respostas e fazer parsing de JSON.

Isso quebraria o princípio da responsabilidade única e deixaria o código muito acoplado. Por exemplo, se no futuro a API fosse substituída por um banco de dados local, seria necessário mexer diretamente no ViewModel, o que poderia impactar toda a lógica de estado da interface.

### 3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

Se a interface acessasse o DataSource diretamente, perderíamos toda a organização que a arquitetura em camadas proporciona. A tela ficaria acoplada aos detalhes de como os dados são buscados, e qualquer mudança na fonte de dados exigiria alterações diretamente na UI.

Além disso, sem o ViewModel no meio, não haveria um gerenciamento centralizado de estado. A interface teria que lidar sozinha com os cenários de loading, erro e sucesso, e também não teria como decidir entre usar o cache ou a API, já que essa lógica pertence ao repositório. No geral, o código ficaria mais frágil e difícil de manter.

### 4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

Bastaria criar um novo DataSource que leia os dados de um banco local, como SQLite, e ajustar o `ProductRepositoryImpl` para usar esse novo DataSource no lugar do `ProductRemoteDatasource`.

O restante da aplicação não precisaria ser alterado. A entidade `Product` continua a mesma, o contrato `ProductRepository` no domínio não muda, o ViewModel continua chamando `repository.getProducts()` normalmente, e a interface segue reagindo aos mesmos estados. Isso funciona porque as camadas superiores dependem de abstrações e não de implementações concretas, então trocar a origem dos dados é uma mudança isolada na camada de dados.
