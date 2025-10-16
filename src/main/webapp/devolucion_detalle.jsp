<%-- 
    Document   : devolucion_detalle
    Created on : 15/10/2025, 20:27:51
    Author     : rodri
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Detalle de devolución | NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple-5">
</head>
<body>
<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Detalle de devolución</h2>
    <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/devoluciones.jsp">&laquo; Volver</a>
  </div>

  <div class="card mb-3">
    <div class="card-body" id="cabecera"><span class="text-muted">Cargando…</span></div>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table class="table table-striped table-hover align-middle mb-0">
        <thead>
          <tr>
            <th>ID Detalle</th>
            <th>Detalle Venta</th>
            <th>Producto</th>
            <th>Cantidad</th>
          </tr>
        </thead>
        <tbody id="tbody"></tbody>
      </table>
    </div>
  </div>
</div>

<script>
/* === Config === */
const API_DEV = 'http://localhost:8080/api/devoluciones';
const CTX      = '<%= request.getContextPath() %>';

/* === Utils === */
function qs(name){
  var url = new URL(window.location.href);
  return url.searchParams.get(name);
}
function money(n){
  if(n==null || n==='' || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
function val(x){ return (x===undefined || x===null) ? '' : String(x); }

/* === Renders (sin template literals para no chocar con EL) === */
function renderHeader(h){
  var html  = '';
  html += '<div class="row g-2">';
  html +=   '<div class="col-md-3"><b>Número:</b> ' + val(h.numero_devolucion||h.numeroDevolucion) + '</div>';
  html +=   '<div class="col-md-3"><b>Fecha:</b> ' + val(h.fecha_devolucion||h.fechaDevolucion) + '</div>';
  html +=   '<div class="col-md-2"><b>Venta ID:</b> ' + val(h.venta_id||h.ventaId) + '</div>';
  html +=   '<div class="col-md-2"><b>Aprobada por:</b> ' + val(h.aprobada_por||h.aprobadaPor) + '</div>';
  html += '</div>';

  html += '<div class="row g-2 mt-2">';
  html +=   '<div class="col-md-2"><b>Total:</b> <span class="badge ok">' + money(h.total_devolucion||h.totalDevolucion) + '</span></div>';
  html +=   '<div class="col-md-2"><b>Estado:</b> ' + val(h.estado) + '</div>';
  html +=   '<div class="col-md-8"><b>Obs.:</b> ' + val(h.observaciones||h.obs) + '</div>';
  html += '</div>';

  document.getElementById('cabecera').innerHTML = html;
}

function renderDetalle(items){
  var tbody = document.querySelector('#tabla tbody');
  tbody.innerHTML = '';
  (items||[]).forEach(function(d){
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + val(d.detalle_id||d.id) + '</td>'
      + '<td>' + val(d.producto_id||d.productoId) + '</td>'
      + '<td>' + val(d.cantidad) + '</td>';
    tbody.appendChild(tr);
  });
}

/* === Carga === */
async function cargar(){
  try{
    var id = qs('id');
    if(!id) throw new Error('Falta parámetro ?id=');
    var res = await fetch(API_DEV + '/' + encodeURIComponent(id));
    var data = await res.json().catch(function(){ return {}; });
    if(!res.ok) throw new Error((data && (data.detail||data.error)) || 'No se pudo cargar la devolución');

    // El endpoint devuelve { header: {...}, detalle: [...] }
    renderHeader(data.header || {});
    renderDetalle(data.detalle || []);
  }catch(err){
    var cab = document.getElementById('cabecera');
    cab.innerHTML = '<div class="alert alert-danger">Error: ' + (err.message||'desconocido') + '</div>';
    document.querySelector('#tabla tbody').innerHTML = '';
  }
}

window.addEventListener('DOMContentLoaded', cargar);
</script>

</body>
</html>

