import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:sanchez_marin/ServicioObject.dart';
import 'package:sanchez_marin/NuevoServicio.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show Future;

class NuevoServicio extends StatefulWidget {
  String titulo;
  ServicioObject oCliente = ServicioObject();
  int codigoServicioSeleccionado = 0;
  String urlGeneral = 'http://wscibertec2021.somee.com/Servicio';
  String urlListarCodigoServicio = "/Listar?CodigoServicio=";

  String mensaje = "";
  bool validacion = false;

  NuevoServicio(this.titulo, this.codigoServicioSeleccionado);

  @override
  _NuevoServicio createState() => _NuevoServicio();
}

class _NuevoServicio extends State<NuevoServicio> {
  final _tfNombreCliente = TextEditingController();
  final _tfNumeroOrdenServicio = TextEditingController();
  final _tfFechaProgramada = TextEditingController();
  final _tfLinea = TextEditingController();
  final _tfEstado = TextEditingController();
  final _tfObservaciones = TextEditingController();
  @override
  void initState() {
    super.initState();
    widget.oCliente.inicializar();
    if (widget.codigoServicioSeleccionado > 0) {
      _listarKey();
    }
  }

  Future<String> _listarKey() async {
    String urlListaServicios = "";
    urlListaServicios = widget.urlGeneral +
        widget.urlListarCodigoServicio +
        widget.codigoServicioSeleccionado.toString();

    final respuesta = await http.get(urlListaServicios);
    final jsonresponse = json.decode(respuesta.body);
    setState(() {
      widget.oCliente = ServicioObject.fromJson(jsonresponse[0]);
      if (widget.oCliente.CodigoServicio > 0) {
        widget.mensaje = "Estas actualizando los datos";
        _mostrarDatos();
      }
    });

    return "Procesado";
  }

  void _mostrarDatos() {
    _tfNombreCliente.text = widget.oCliente.NombreCliente;
    _tfNumeroOrdenServicio.text = widget.oCliente.NumeroOrdenServicio;
    _tfFechaProgramada.text = widget.oCliente.FechaProgramada;
    _tfLinea.text = widget.oCliente.Linea;
    _tfEstado.text = widget.oCliente.Estado;
    _tfObservaciones.text = widget.oCliente.Observaciones;
  }

  bool _validarRegistro() {
    if (_tfNombreCliente.text.toString() == "" ||
        _tfNumeroOrdenServicio.text.toString() == "") {
      widget.validacion = false;
      setState(() {
        widget.mensaje = "Falta ingresar datos";
      });
      return false;
    }
    return true;
  }

  void _grabarRegistro() {
    if (_validarRegistro()) {
      _ejecutarServicio();
    }
  }

  Future<String> _ejecutarServicio() async {
    String accion = "N";
    if (widget.oCliente.CodigoServicio > 0) {
      accion = "A";
    }
    String strParametros = "/RegistraModifica?Accion=";
    strParametros += accion;
    strParametros +=
        "&CodigoServicio=" + widget.oCliente.CodigoServicio.toString();
    strParametros += "&NombreCliente=" + _tfNombreCliente.text;
    strParametros += "&NumeroOrdenServicio=" + _tfNumeroOrdenServicio.text;
    strParametros += "&Fechaprogramada=" + _tfFechaProgramada.text;
    strParametros += "&Linea=" + _tfLinea.text;
    strParametros += "&Estado=" + _tfEstado.text;
    strParametros += "&Observaciones=" + _tfObservaciones.text;

    String urlRegistroClientes = "";
    urlRegistroClientes = widget.urlGeneral + strParametros;
    final respuesta = await http.get(urlRegistroClientes);
    final data = respuesta.body;
    setState(() {
      widget.oCliente = ServicioObject.fromJson(json.decode(data));
      if (widget.oCliente.CodigoServicio > 0) {
        widget.mensaje = "Grabado correctamente";
      }
    });
    return "Procesado";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de Servicios " + widget.titulo),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text("Código de cliente: " +
                widget.oCliente.CodigoServicio.toString()),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              children: <Widget>[
                TextField(
                    controller: _tfNombreCliente,
                    decoration: InputDecoration(
                      hintText: "Ingresar Nombre del cliente",
                      labelText: "Nombre del Cliente",
                    )),
                TextField(
                    controller: _tfNumeroOrdenServicio,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration(
                      hintText: "Ingrese el nro de orden",
                      labelText: "Nro de orden",
                    )),
                TextField(
                    controller: _tfFechaProgramada,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration(
                      hintText: "Ingrese la fecha programada",
                      labelText: "Fecha",
                    )),
                TextField(
                    controller: _tfLinea,
                    decoration: InputDecoration(
                      hintText: "Ingrese linea",
                      labelText: "Línea",
                    )),
                TextField(
                    controller: _tfEstado,
                    decoration: InputDecoration(
                      hintText: "Ingresar el estado",
                      labelText: "Estado",
                    )),
                TextField(
                    controller: _tfObservaciones,
                    decoration: InputDecoration(
                      hintText: "Ingresar la observación",
                      labelText: "Observación",
                    )),
                RaisedButton(
                  color: Colors.grey[500].withOpacity(0.7),
                  child: Text(
                    "Grabar",
                    style: TextStyle(fontSize: 18, fontFamily: "rbold"),
                  ),
                  onPressed: _grabarRegistro,
                ),
                Text("Mensaje: " + widget.mensaje),
              ],
            ),
          )
        ],
      ),
    );
  }
}
