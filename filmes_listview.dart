import 'package:flutter/material.dart';
import '../models/filme_item.dart';

class FilmesListView extends StatelessWidget {
  const FilmesListView({super.key, required this.filmes});

  final List<FilmeItem> filmes;

  @override
  Widget build(BuildContext context) {
    // DESAFIO 1: Substituído ListView com for loop por ListView.builder.
    // O ListView.builder constrói os itens sob demanda (lazy loading),
    // ou seja, apenas os widgets visíveis na tela são criados.
    // Isso evita desperdício de memória e processamento em listas grandes.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: filmes.length,
      itemBuilder: (context, index) {
        final FilmeItem filme = filmes[index];

        // DESAFIO 2: Envolvemos o card com InkWell para adicionar interatividade.
        // O InkWell fornece feedback visual nativo do Material Design (efeito ripple)
        // ao toque, e o onTap exibe um SnackBar com o título do filme selecionado.
        return Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Você selecionou: ${filme.titulo}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 27 / 40,
                    child: Image.network(
                      filme.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return Container(
                          color: const Color(0xFFB0BEC5),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      filme.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}