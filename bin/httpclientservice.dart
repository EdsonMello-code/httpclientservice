import 'dart:convert';
import 'dart:io';

Future<void> uploadFile() async {
  final httpClient = HttpClient();

  try {
    // Define o URI do endpoint
    final uri = Uri(
      scheme: 'https',
      host: 'api.example.com',
      path: '/upload',
    );

    // Cria a requisição POST
    final request = await httpClient.postUrl(uri);

    // Configura o cabeçalho para multipart/form-data
    final boundary =
        '----DartBoundary'; // Delimitador único para separar as partes
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    // Dados adicionais no formulário
    final additionalData = {
      'field1': 'value1',
      'field2': 'value2',
    };

    // Caminho para o arquivo a ser enviado
    final filePath =
        'path/to/your/file.txt'; // Substitua pelo caminho do seu arquivo
    final file = File(filePath);

    if (!await file.exists()) {
      print('Erro: Arquivo não encontrado.');
      return;
    }

    // Monta o corpo multipart
    final body = StringBuffer();
    additionalData.forEach((key, value) {
      body.write('--$boundary\r\n');
      body.write('Content-Disposition: form-data; name="$key"\r\n\r\n');
      body.write('$value\r\n');
    });

    // Adiciona o arquivo ao corpo
    body.write('--$boundary\r\n');
    body.write(
        'Content-Disposition: form-data; name="file"; filename="${file.uri.pathSegments.last}"\r\n');
    body.write('Content-Type: application/octet-stream\r\n\r\n');

    // Escreve o cabeçalho e as partes anteriores
    request.write(body.toString());

    // Escreve o conteúdo do arquivo
    await request.addStream(file.openRead());

    // Finaliza o corpo multipart
    request.write('\r\n--$boundary--\r\n');

    // Envia a requisição e lê a resposta
    final response = await request.close();

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Upload realizado com sucesso: $responseBody');
    } else {
      print('Erro no upload: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro na requisição: $e');
  } finally {
    // Fecha o HttpClient
    httpClient.close();
  }
}

void main() {
  uploadFile();
}
