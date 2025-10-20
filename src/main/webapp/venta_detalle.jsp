<%--
  Document   : venta_detalle (solo lectura)
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
  <script src="assets/js/common.js?v=99"></script>
</head>
<body>
<div class="container py-4">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Detalle de venta</h2>
    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/ventas.jsp">&laquo; Volver</a>
  </div>

  <!-- Cabecera -->
  <div class="card mb-3">
    <div class="card-body" id="cabecera">
      <div class="text-muted">Cargando venta...</div>
    </div>
  </div>

  <!-- Detalle (líneas) -->
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
    <div id="tablaEmpty" class="p-3 text-muted d-none">Esta venta no tiene líneas.</div>
  </div>
</div>

<script>
// === Config/ENDPOINTS ===
const API_BASE = 'http://localhost:8080/api/ventas';

// === Utils ===
function qs(name){ var u = new URL(window.location.href); return u.searchParams.get(name); }
function money(n){
  if(n==null || n==='' || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
function txt(x){ return (x===undefined || x===null) ? '' : String(x); }
async function fetchJson(url, opts){
  const res = await fetch(url, opts||{});
  const txtRes = await res.text();
  let data = null;
  try{ data = txtRes ? JSON.parse(txtRes) : null; }catch{}
  if(!res.ok) throw new Error((data && (data.error||data.detail)) || ('HTTP '+res.status));
  return data;
}
function mapTipoPago(c){ if(!c) return ''; return c==='C'?'Contado':(c==='R'?'Crédito':c); }
function estadoBadge(e){
  if(e==='A') return '<span class="badge text-bg-danger">Anulada</span>';
  if(e==='P') return '<span class="badge ok">Procesada</span>';
  return '<span class="badge text-bg-secondary">Desconocido</span>';
}

// === Render ===
function renderCabecera(v){
  var cliente = (v && v.clienteNombre && String(v.clienteNombre).trim()!=='')
                ? v.clienteNombre : ('ID ' + txt(v && v.clienteId));

  var html = ''
    + '<div class="row g-2">'
    +   '<div class="col-md-3"><b>Número:</b> ' + txt(v && v.numeroVenta) + '</div>'
    +   '<div class="col-md-3"><b>Fecha:</b> ' + txt(v && v.fechaVenta) + '</div>'
    +   '<div class="col-md-6"><b>Cliente:</b> ' + cliente + '</div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    +   '<div class="col-md-3"><b>Tipo Pago:</b> ' + mapTipoPago(v && v.tipoPago) + '</div>'
    +   '<div class="col-md-3"><b>Estado:</b> ' + estadoBadge(v && v.estado) + '</div>'
    +   '<div class="col-md-3"><b>VendedorID:</b> ' + txt(v && v.vendedorId) + '</div>'
    +   '<div class="col-md-3"><b>CajeroID:</b> ' + txt(v && v.cajeroId) + '</div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    +   '<div class="col-md-3"><b>Subtotal:</b> ' + money(v && v.subtotal) + '</div>'
    +   '<div class="col-md-3"><b>Descuento:</b> ' + money(v && v.descuentoGeneral) + '</div>'
    +   '<div class="col-md-3"><b>IVA:</b> ' + money(v && v.iva) + '</div>'
    +   '<div class="col-md-3"><span class="badge ok">Total ' + money(v && v.total) + '</span></div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    +   '<div class="col-md-12"><b>Observaciones:</b> ' + txt(v && v.observaciones) + '</div>'
    + '</div>';

  document.getElementById('cabecera').innerHTML = html;
}

function renderDetalles(items){
  var tbody = document.querySelector('#tabla tbody');
  var empty = document.getElementById('tablaEmpty');
  tbody.innerHTML = '';

  if(!items || !items.length){
    if (empty) empty.classList.remove('d-none');
    return;
  }
  if (empty) empty.classList.add('d-none');

  for (var i=0;i<items.length;i++){
    var d = items[i];
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + txt(d && d.id) + '</td>'
      + '<td>' + txt(d && d.productoId) + '</td>'
      + '<td>' + txt(d && d.cantidad) + '</td>'
      + '<td>' + money(d && d.precioUnitario) + '</td>'
      + '<td>' + money(d && d.descuentoLinea) + '</td>'
      + '<td>' + money(d && d.subtotal) + '</td>'
      + '<td>' + txt(d && d.lote) + '</td>'
      + '<td>' + txt(d && d.fechaVencimiento) + '</td>';
    tbody.appendChild(tr);
  }
}

// === Carga ===
async function cargar(){
  try{
    var id = qs('id');
    if(!id) throw new Error('Falta parámetro ?id=');
    var venta = await fetchJson(API_BASE + '/' + id);
    renderCabecera(venta);
    renderDetalles(venta && venta.items);
  }catch(err){
    console.error(err);
    document.getElementById('cabecera').innerHTML =
      '<div class="alert alert-danger">Error: ' + (err.message || 'desconocido') + '</div>';
  }
}

// === Boot ===
window.addEventListener('DOMContentLoaded', cargar);
</script>
</body>
</html>
