<%--
  Document   : venta_detalle
  Created on : 09/10/2025
  Author     : user
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Detalle de venta | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-fix4">
</head>
<body>
<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Detalle de venta</h2>
    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/ventas.jsp">&laquo; Volver</a>
  </div>

  <div class="card mb-3">
    <div class="card-body" id="cabecera">
      <div class="text-muted">Cargando venta...</div>
    </div>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table id="tabla" class="table table-striped table-hover align-middle mb-0">
        <thead>
        <tr>
          <th>ID Detalle</th>
          <th>Producto ID</th>
          <th>Cantidad</th>
          <th>Precio</th>
          <th>Desc. línea</th>
          <th>Subtotal</th>
          <th>Lote</th>
          <th>Vence</th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>

<script>
/* === Config === */
const API = 'http://localhost:8080/api/ventas';
const CTX = '${pageContext.request.contextPath}';

/* === Utils === */
function qs(name){
  var url = new URL(window.location.href);
  return url.searchParams.get(name);
}
function formatMoney(n){
  if(n==null || n=== '' || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
function val(x){ return (x===undefined || x===null) ? '' : String(x); }

/* === Render === */
function renderCabecera(v){
  var cliente = (v && v.clienteNombre && String(v.clienteNombre).trim() !== '')
      ? v.clienteNombre : ('ID ' + val(v && v.clienteId));

  var html = ''
    + '<div class="row g-2">'
    +   '<div class="col-md-2"><b>Número:</b> ' + val(v && v.numeroVenta) + '</div>'
    +   '<div class="col-md-2"><b>Fecha:</b> ' + val(v && v.fechaVenta) + '</div>'
    +   '<div class="col-md-4"><b>Cliente:</b> ' + cliente + '</div>'
    +   '<div class="col-md-2"><b>Tipo Pago:</b> ' + val(v && v.tipoPago) + '</div>'
    +   '<div class="col-md-2"><b>Estado:</b> ' + val(v && v.estado) + '</div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    +   '<div class="col-md-2"><b>Subtotal:</b> ' + formatMoney(v && v.subtotal) + '</div>'
    +   '<div class="col-md-2"><b>Descuento:</b> ' + formatMoney(v && v.descuentoGeneral) + '</div>'
    +   '<div class="col-md-2"><b>IVA:</b> ' + formatMoney(v && v.iva) + '</div>'
    +   '<div class="col-md-2"><span class="badge ok">Total ' + formatMoney(v && v.total) + '</span></div>'
    +   '<div class="col-md-4"><b>Obs.:</b> ' + val(v && v.observaciones) + '</div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    +   '<div class="col-md-2"><b>VendedorID:</b> ' + val(v && v.vendedorId) + '</div>'
    +   '<div class="col-md-2"><b>CajeroID:</b> ' + val(v && v.cajeroId) + '</div>'
    +   '<div class="col-md-2"><b>Bodega:</b> ' + val(v && v.bodegaOrigenId) + '</div>'
    + '</div>';

  document.getElementById('cabecera').innerHTML = html;
}

function renderDetalles(items){
  var tbody = document.querySelector('#tabla tbody');
  tbody.innerHTML = '';
  (items || []).forEach(function(d){
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + val(d && d.id) + '</td>'
      + '<td>' + val(d && d.productoId) + '</td>'
      + '<td>' + val(d && d.cantidad) + '</td>'
      + '<td>' + formatMoney(d && d.precioUnitario) + '</td>'
      + '<td>' + formatMoney(d && d.descuentoLinea) + '</td>'
      + '<td>' + formatMoney(d && d.subtotal) + '</td>'
      + '<td>' + val(d && d.lote) + '</td>'
      + '<td>' + val(d && d.fechaVencimiento) + '</td>';
    tbody.appendChild(tr);
  });
}

/* === Carga === */
async function cargar(){
  try{
    var id = qs('id');
    if (!id) throw new Error('Falta parámetro ?id=');
    var res = await fetch(API + '/' + id);
    var venta = await res.json().catch(function(){ return {}; });
    if (!res.ok) throw new Error((venta && venta.error) || 'No se pudo cargar la venta');
    renderCabecera(venta);
    renderDetalles(venta && venta.items);
  }catch(err){
    console.error(err);
    var cab = document.getElementById('cabecera');
    cab.innerHTML = '<div class="alert alert-danger">Error: ' + (err.message || 'desconocido') + '</div>';
  }
}

window.addEventListener('DOMContentLoaded', cargar);
</script>
</body>
</html>
