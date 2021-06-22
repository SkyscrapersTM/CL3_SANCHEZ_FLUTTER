import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:sanchez_marin/ServicioObject.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show Future;
import 'package:sanchez_marin/NuevoServicio.dart';

class ListadoServicios extends StatefulWidget {
  String titulo;
  List<ServicioObject> oListaClientes = [];
  int CodigoServicioSeleccionado = 0;
  String urlGeneral = 'http://wscibertec2021.somee.com/Servicio';
  String urlListado = "/Listar?NombreCliente=";
  String urlParam = "&NumeroOrdenServicio=";
  ListadoServicios(this.titulo);

  String jsonServicios =
      '[{"CodigoServicio":0,"NombreCliente":"","NumeroOrdenServicio":"","FechaProgramada":"","Linea":"","Estado":"","Observaciones":"","Eliminado":false,"CodigoError":0,"DescripcionError":"","MensajeError":null}]';
  @override
  State<StatefulWidget> createState() => _ListadoServicios();
}

class _ListadoServicios extends State<ListadoServicios> {
  final _tfnombreCliente = TextEditingController();
  final _tfNumeroOrdenServicio = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<String> _consultarServicios() async {
    String urlListaServicios = "";
    urlListaServicios = widget.urlGeneral +
        widget.urlListado +
        _tfnombreCliente.text.toString() +
        widget.urlParam +
        _tfNumeroOrdenServicio.text.toString();

    var respuesta = await http.get(urlListaServicios);
    var data = respuesta.body;
    var oListaServicioTmp = List<ServicioObject>.from(
        json.decode(data).map((x) => ServicioObject.fromJson(x)));

    setState(() {
      widget.oListaClientes = oListaServicioTmp;
      widget.jsonServicios = data;

      if (widget.oListaClientes.length == 0) {
        widget.jsonServicios =
            '[{"CodigoServicio":0,"NombreCliente":"","NumeroOrdenServicio":"","FechaProgramada":"","Linea":"","Estado":"","Observaciones":"","Eliminado":false,"CodigoError":0,"DescripcionError":"","MensajeError":null}]';
      }
    });
    return "Procesado";
  }

  void _nuevoServicio() {
    Navigator.of(context)
        .push(new MaterialPageRoute<Null>(builder: (BuildContext pContext) {
      return new NuevoServicio("", widget.CodigoServicioSeleccionado);
    }));
  }

  @override
  Widget build(BuildContext context) {
    var json = jsonDecode(widget.jsonServicios);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Consulta de Servicios",
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Para consultar completar el nombre del cliente, código de orden y dar click en Consultar",
              style: TextStyle(fontSize: 12),
            ),
            TextField(
              controller: _tfnombreCliente,
              decoration: InputDecoration(
                  hintText: "Ingrese nombre del cliente",
                  labelText: "Nombre Cliente"),
            ),
            TextField(
              controller: _tfNumeroOrdenServicio,
              decoration: InputDecoration(
                  hintText: "Ingrese código de orden",
                  labelText: "Código de orden"),
            ),
            Text(
              "Se encontraron " +
                  widget.oListaClientes.length.toString() +
                  " Clientes",
              style: TextStyle(fontSize: 9),
            ),
            new Table(children: [
              TableRow(children: [
                Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: RaisedButton(
                    color: Colors.greenAccent,
                    child: Text(
                      "Consultar",
                      style: TextStyle(fontSize: 10, fontFamily: "rbold"),
                    ),
                    onPressed: _consultarServicios,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: RaisedButton(
                    color: Colors.greenAccent,
                    child: Text(
                      "Nuevo",
                      style: TextStyle(fontSize: 10, fontFamily: "rbold"),
                    ),
                    onPressed: _nuevoServicio,
                  ),
                )
              ])
            ]),
            JsonTable(
              json,
              showColumnToggle: true,
              allowRowHighlight: true,
              rowHighlightColor: Colors.grey[500].withOpacity(0.7),
              paginationRowCount: 10,
              onRowSelect: (index, map) {
                widget.CodigoServicioSeleccionado =
                    int.parse(map["CodigoServicio"].toString());
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext pContext) {
                  return new NuevoServicio(
                      "", widget.CodigoServicioSeleccionado);
                }));
              },
            )
          ],
        ),
      ),
    );
  }
}
