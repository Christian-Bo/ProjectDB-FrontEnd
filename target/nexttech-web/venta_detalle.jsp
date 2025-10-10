<%-- 
    Document   : venta_detalle
    Created on : 9/10/2025
    Author     : rodri
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Detalle de venta | NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Detalle de venta</h2>
    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ventas.jsp">&laquo; Volver</a>
  </div>

  <div class="card mb-3">
    <div class="card-body" id="cabecera"></div>
  </div>

  <div class="card">
    <div class="card-body">
      <h3 class="h5">Items</h3>
      <div class="table-responsive mt-2">
        <table id="tabla" class="table table-dark table-striped table-borderless align-middle mb-0">
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
</div>

<script>
const API = 'http://localhost:8080/api/ventas';

function qs(name){ const url = new URL(window.location.href); return url.searchParams.get(name); }
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
  const cliente = (v.clienteNombre && v.clienteNombre.trim() !== '') ? v.clienteNombre : ('ID ' + v.clienteId);
  const tipoPago = (v.tipoPago ?? '');
  const estado = (v.estado ?? '');

  cab.innerHTML = `
    <div class="row g-3">
      <div class="col-md-3"><b style="color:var(--color-principal)">Número:</b> ${'${'}v.numeroVenta}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Fecha:</b> ${'${'}v.fechaVenta}</div>
      <div class="col-md-6"><b style="color:var(--color-principal)">Cliente:</b> ${'${'}cliente}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Tipo Pago:</b> ${'${'}tipoPago}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Estado:</b> ${'${'}estado}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Subtotal:</b> ${'${'}v.subtotal}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Descuento:</b> ${'${'}v.descuentoGeneral}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">IVA:</b> ${'${'}v.iva}</div>
      <div class="col-md-3"><span class="badge ok">Total: ${'${'}v.total}</span></div>
      <div class="col-md-9"><b style="color:var(--color-principal)">Obs.:</b> ${'${'}v.observaciones ?? ''}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">VendedorID:</b> ${'${'}v.vendedorId ?? ''}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">CajeroID:</b> ${'${'}v.cajeroId ?? ''}</div>
      <div class="col-md-3"><b style="color:var(--color-principal)">Bodega:</b> ${'${'}v.bodegaOrigenId ?? ''}</div>
    </div>
  `;

  const tbody = document.querySelector('#tabla tbody');
  tbody.innerHTML = '';
  (v.items || []).forEach(d => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${'${'}d.id ?? ''}</td>
      <td>${'${'}d.productoId}</td>
      <td>${'${'}d.cantidad}</td>
      <td>${'${'}d.precioUnitario}</td>
      <td>${'${'}d.descuentoLinea}</td>
      <td>${'${'}d.subtotal}</td>
      <td>${'${'}d.lote ?? ''}</td>
      <td>${'${'}d.fechaVencimiento ?? ''}</td>
    `;
    tbody.appendChild(tr);
  });
}
window.addEventListener('DOMContentLoaded', cargar);
</script>
</body>
</html>
