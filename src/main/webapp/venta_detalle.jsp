<%-- 
    Document   : venta_detalle
    Created on : 9/10/2025
    Author     : user
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Detalle de venta | NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple">
</head>
<body>
<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Detalle de venta</h2>
    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/ventas.jsp">&laquo; Volver</a>
  </div>

  <div class="card mb-3">
    <div class="card-body" id="cabecera"></div>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table id="tabla" class="table table-striped align-middle mb-0">
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
const API = 'http://localhost:8080/api/ventas';

function qs(name){
  const url = new URL(window.location.href);
  return url.searchParams.get(name);
}
function formatMoney(n){ if(n==null) return ''; return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(n); }

async function cargar(){
  const id = qs('id');
  if (!id) { alert('Falta ?id='); return; }
  const res = await fetch(API + '/' + id);
  const venta = await res.json();
  if (!res.ok) { alert((venta && venta.error) || 'No se pudo cargar la venta'); return; }
  render(venta);
}
function render(v){
  const cab = document.getElementById('cabecera');
  const cliente = (v.clienteNombre && v.clienteNombre.trim() !== '')
      ? v.clienteNombre : ('ID ' + v.clienteId);

  cab.innerHTML = `
    <div class="row g-2">
      <div class="col-md-2"><b>Número:</b> ${v.numeroVenta}</div>
      <div class="col-md-2"><b>Fecha:</b> ${v.fechaVenta}</div>
      <div class="col-md-4"><b>Cliente:</b> ${cliente}</div>
      <div class="col-md-2"><b>Tipo Pago:</b> ${v.tipoPago || ''}</div>
      <div class="col-md-2"><b>Estado:</b> ${v.estado || ''}</div>
    </div>
    <div class="row g-2 mt-2">
      <div class="col-md-2"><b>Subtotal:</b> ${formatMoney(v.subtotal)}</div>
      <div class="col-md-2"><b>Descuento:</b> ${formatMoney(v.descuentoGeneral)}</div>
      <div class="col-md-2"><b>IVA:</b> ${formatMoney(v.iva)}</div>
      <div class="col-md-2"><span class="badge ok">Total ${formatMoney(v.total)}</span></div>
      <div class="col-md-4"><b>Obs.:</b> ${v.observaciones || ''}</div>
    </div>
    <div class="row g-2 mt-2">
      <div class="col-md-2"><b>VendedorID:</b> ${v.vendedorId || ''}</div>
      <div class="col-md-2"><b>CajeroID:</b> ${v.cajeroId || ''}</div>
      <div class="col-md-2"><b>Bodega:</b> ${v.bodegaOrigenId || ''}</div>
    </div>
  `;

  const tbody = document.querySelector('#tabla tbody');
  tbody.innerHTML = '';
  (v.items || []).forEach(d => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${d.id || ''}</td>
      <td>${d.productoId}</td>
      <td>${d.cantidad}</td>
      <td>${formatMoney(d.precioUnitario)}</td>
      <td>${formatMoney(d.descuentoLinea)}</td>
      <td>${formatMoney(d.subtotal)}</td>
      <td>${d.lote || ''}</td>
      <td>${d.fechaVencimiento || ''}</td>
    `;
    tbody.appendChild(tr);
  });
}
window.addEventListener('DOMContentLoaded', cargar);
</script>
</body>
</html>
