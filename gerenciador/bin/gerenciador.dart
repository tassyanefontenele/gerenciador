import 'package:gerenciador/gerenciador.dart' as gerenciador;
import 'dart:io';

void main(List<String> arguments) {
  final gerenciador = GerenciadorTarefas();
  while (true) {
    print('\n--- GERENCIADOR DE TAREFAS (CLI) ---');
    print('1. Criar nova tarefa');
    print('2. Listar tarefas');
    print('3. Editar tarefa');
    print('4. Excluir tarefa');
    print('5. Alternar status (Finalizada/Pendente)');
    print('0. Sair');
    stdout.write('Escolha uma opção: ');

    // Leitura da opção do usuário
    final escolha = stdin.readLineSync();

    // Verificamos a opção escolhida pelo usuário
    switch (escolha) {
      case '1':
        print('\n--- CRIAR NOVA TAREFA ---');
        stdout.write('Título da Tarefa: ');
        final titulo = stdin.readLineSync();

        if (titulo == null || titulo.isEmpty) {
          print('❌ O título não pode ser vazio. Tente novamente.');
          continue;
        }

        stdout.write('Descrição (Opcional): ');
        final descricao = stdin.readLineSync();

        gerenciador.adicionarTarefa(
          titulo: titulo,
          descricao: (descricao != null && descricao.isNotEmpty)
              ? descricao
              : null,
        );
        break;
      case '2':
        gerenciador.listarTarefas();
        break;
      case '3':
        print('\n--- EDITAR TAREFA ---');
        gerenciador.listarTarefas();
        stdout.write('ID da Tarefa para editar: ');
        final entradaId = stdin.readLineSync();
        final idEditar = int.tryParse(entradaId ?? '');

        if (idEditar == null) {
          print('❌ ID inválido. Por favor, digite um número.');
          continue;
        }

        stdout.write('Novo Título (deixe em branco para não alterar): ');
        final novoTituloLido = stdin.readLineSync();
        stdout.write('Nova Descrição (deixe em branco para não alterar): ');
        final novaDescricaoLida = stdin.readLineSync();
        final String? novoTitulo =
            (novoTituloLido != null && novoTituloLido.isNotEmpty)
            ? novoTituloLido
            : null;
        final String? novaDescricao =
            (novaDescricaoLida != null && novaDescricaoLida.isNotEmpty)
            ? novaDescricaoLida
            : null;
        final sucesso = gerenciador.editarTarefa(
          id: idEditar,
          novoTitulo: novoTitulo,
          novaDescricao: novaDescricao,
        );
        break;
      case '4':
        print('\n--- EXCLUIR TAREFA ---');
        gerenciador.listarTarefas();
        stdout.write('ID da Tarefa a excluir: ');
        final entradaId = stdin.readLineSync();
        final idExcluir = int.tryParse(entradaId ?? '');

        if (idExcluir == null) {
          print('❌ ID inválido. Por favor, digite um número.');
          continue;
        }

        final sucesso = gerenciador.excluirTarefa(idExcluir);
        break;
      case '5':
        print('\n--- ALTERNAR STATUS DE TAREFA ---');
        gerenciador.listarTarefas();
        stdout.write('ID da Tarefa para alterar o status: ');
        final entradaId = stdin.readLineSync();
        final idAlterar = int.tryParse(entradaId ?? '');

        if (idAlterar == null) {
          print('❌ ID inválido. Por favor, digite um número.');
          continue; // Volta ao menu
        }

        final sucesso = gerenciador.alternarFinalizacao(idAlterar);
        break;
      case '0':
        print('Programa Encerrado!');
        return;
      default:
        print('Opção inválida. Tente novamente.');
    }
  }
}

class GerenciadorTarefas {
  // Lista de Tarefas criadas
  final List<Tarefa> _tarefas = [];

  int _proximoId = 1;

  List<Tarefa> get tarefas => _tarefas;

  void adicionarTarefa({required String titulo, String? descricao}) {
    final novaTarefa = Tarefa(
      id: _proximoId,
      titulo: titulo,
      descricao: descricao,
    );
    _tarefas.add(novaTarefa);
    _proximoId++;
  }

  void listarTarefas() {
    if (_tarefas.isEmpty) {
      print('Nenhuma tarefa encontrada!');
      return;
    }

    print('\n--- LISTA DE TAREFAS (${_tarefas.length}) ---');
    _tarefas.forEach((tarefa) {
      print(tarefa.toString());
    });

    print('--------------------------------------');
  }

  Tarefa? _encontrarTarefaPorId(int id) {
    try {
      return _tarefas.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  bool editarTarefa({
    required int id,
    String? novoTitulo,
    String? novaDescricao,
  }) {
    final tarefaParaEditar = _encontrarTarefaPorId(id);

    if (tarefaParaEditar != null) {
      if (novoTitulo != null) {
        tarefaParaEditar.titulo = novoTitulo;
      }
      if (novaDescricao != null) {
        tarefaParaEditar.descricao = novaDescricao;
      }
      return true;
    }
    return false;
  }

  bool excluirTarefa(int id) {
    final tarefaParaExcluir = _encontrarTarefaPorId(id);

    if (tarefaParaExcluir != null) {
      _tarefas.remove(tarefaParaExcluir);
      return true;
    }
    return false;
  }

  bool alternarFinalizacao(int id) {
    final tarefaParaAlterar = _encontrarTarefaPorId(id);

    if (tarefaParaAlterar != null) {
      tarefaParaAlterar.alternarStatus();
      return true;
    }
    return false;
  }
}

class Tarefa {
  int id;
  String titulo;
  String? descricao;
  bool finalizada;

  Tarefa({
    required this.id,
    required this.titulo,
    this.descricao, // Opcional (se não for passado, será null)
    this.finalizada = false,
  });

  @override
  String toString() {
    final status = finalizada ? '✅ FINALIZADA' : '⏳ PENDENTE';
    return '$id. [$status] $titulo' +
        (descricao != null ? ' - $descricao' : '');
  }

  void alternarStatus() {
    finalizada = !finalizada; // Inverte o valor atual
  }
}
