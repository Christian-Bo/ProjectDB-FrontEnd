<%-- 
    Document   : devoluciones
    Created on : 15/10/2025, 20:26:59
    Author     : user
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Devoluciones | NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple-5">
</head>
<body>
<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Devoluciones</h2>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNuevaDev">+ Nueva devolución</button>
  </div>

  <div class="card mb-3">
    <div class="card-body">
      <form id="filtros" onsubmit="buscar(event)" class="row g-3">
        <div class="col-md-3">
          <label class="form-label">Desde</label>
          <input type="date" name="desde" class="form-control"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Hasta</label>
          <input type="date" name="hasta" class="form-control"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Cliente ID</label>
          <input type="number" min="1" name="clienteId" class="form-control" placeholder="Ej. 1"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Venta ID</label>
          <input type="number" min="1" name="ventaId" class="form-control" placeholder="Ej. 14"/>
        </div>
        <div class="col-12 d-flex gap-2 justify-content-end">
          <button class="btn btn-primary" type="submit">Buscar</button>
          <button class="btn btn-outline-secondary" type="button" onclick="limpiar()">Limpiar</button>
        </div>
      </form>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="d-flex align-items-center gap-2 pager">
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(-1)">&laquo; Anterior</button>
      <div> Página <span id="pActual">1</span> </div>
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(1)">Siguiente &raquo;</button>
    </div>
    <small class="text-muted">Mostrando 10 por página</small>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table class="table table-striped table-hover align-middle mb-0" id="tabla">
        <thead>
        <tr>
          <th>ID</th>
          <th>Número</th>
          <th>Fecha</th>
          <th>Venta</th>
          <th>Cliente</th>
          <th class="text-end">Total</th>
          <th>Estado</th>
          <th class="text-end">Acciones</th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
    <div id="tablaEmpty" class="p-3 text-muted d-none">Sin resultados para los filtros actuales.</div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed bottom-0 end-0 p-3" style="z-index:1080;">
    <div id="toastOk" class="toast align-items-center text-bg-success border-0" role="alert">
      <div class="d-flex">
        <div class="toast-body" id="okMsg">Acción completada.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    </div>
    <div id="toastErr" class="toast align-items-center text-bg-danger border-0 mt-2" role="alert">
      <div class="d-flex">
        <div class="toast-body" id="errMsg">Ocurrió un error.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    </div>
  </div>
</div>

<!-- Modal Nueva Devolución -->
<div class="modal fade" id="modalNuevaDev" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <form id="formDev" onsubmit="guardarDevolucion(event)">
        <div class="modal-header">
          <h5 class="modal-title">Registrar nueva devolución</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Venta ID *</label>
              <div class="input-group">
                <input type="number" min="1" class="form-control" id="devVentaId" required placeholder="Ej. 14">
                <button class="btn btn-outline-primary" type="button" onclick="cargarVentaParaDevolucion()">Cargar</button>
              </div>
              <div class="form-text">Ingresa el ID de la venta y pulsa “Cargar”.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Aprobada por (usuario) *</label>
              <input type="number" min="1" class="form-control" id="devAprobadaPor" value="1" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Observaciones (opcional)</label>
              <input type="text" class="form-control" id="devObs" placeholder="Motivo general">
            </div>
          </div>

          <hr class="my-4">

          <h6 class="mb-2">Items a devolver</h6>
          <div class="table-responsive">
            <table class="table table-sm table-striped align-middle" id="tablaDevItems">
              <thead>
              <tr>
                <th>ID Detalle Venta</th>
                <th>Producto</th>
                <th>Cant. vendida</th>
                <th>Cant. devolver *</th>
                <th>Obs. línea</th>
              </tr>
              </thead>
              <tbody>
              <tr><td colspan="5" class="text-muted">Carga una venta para ver sus líneas…</td></tr>
              </tbody>
            </table>
          </div>
          <div class="form-text">Solo se enviarán las líneas con cantidad a devolver &gt; 0.</div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" type="button" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn btn-primary" type="submit">Guardar devolución</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Modal Confirmar Anulación -->
<div class="modal fade" id="modalAnular" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Confirmar anulación</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="anularId">
        <p>¿Seguro que deseas anular la devolución <b id="anularNum"></b>?</p>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-danger" onclick="confirmarAnular()">Sí, anular</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ==== Config ====
const API_DEV = 'http://localhost:8080/api/devoluciones';
const ctx     = '${pageContext.request.contextPath}';

// ==== Utils ====
function money(n){
  if(n==null || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
async function fetchJson(url){
  const res = await fetch(url);
  let body = null; try{ body = await res.json(); }catch(e){}
  if(!res.ok){
    const msg = (body && (body.detail || body.error || body.message)) || ('HTTP ' + res.status);
    throw new Error(msg);
  }
  return body;
}
function toArr(p){
  if(Array.isArray(p)) return p;
  if(!p || typeof p!=='object') return [];
  return p.content || p.items || p.data || p.records || [];
}
function toastOk(msg){
  var t = document.getElementById('toastOk');
  var m = document.getElementById('okMsg'); if(m) m.innerText = msg || 'OK';
  new bootstrap.Toast(t).show();
}
function toastErr(msg){
  var t = document.getElementById('toastErr');
  var m = document.getElementById('errMsg'); if(m) m.innerText = msg || 'Error';
  new bootstrap.Toast(t).show();
}

// ==== Tabla ====
let page = 0, size = 10, last = {};

async function cargar(params){
  params = params || {};
  try{
    var qs = new URLSearchParams({ page: page, size: size });
    if(params.desde)     qs.set('desde', params.desde);
    if(params.hasta)     qs.set('hasta', params.hasta);
    if(params.clienteId) qs.set('clienteId', params.clienteId);
    if(params.ventaId)   qs.set('ventaId', params.ventaId);

    var data = await fetchJson(API_DEV + '?' + qs.toString());
    render(toArr(data));
    var pEl = document.getElementById('pActual'); if(pEl) pEl.textContent = (page+1);
  }catch(err){
    toastErr('Devoluciones: ' + err.message);
    render([]);
  }
}

function render(rows){
  var tb = document.querySelector('#tabla tbody');
  var empty = document.getElementById('tablaEmpty');
  tb.innerHTML = '';
  if(!rows.length){ if(empty) empty.classList.remove('d-none'); return; }
  if(empty) empty.classList.add('d-none');

  rows.forEach(function(d){
    var id    = (d.id!=null ? d.id : (d.devolucion_id!=null ? d.devolucion_id : ''));
    var num   = (d.numero_devolucion!=null ? d.numero_devolucion : (d.numeroDevolucion!=null ? d.numeroDevolucion : ''));
    var fec   = (d.fecha_devolucion!=null ? d.fecha_devolucion : (d.fechaDevolucion!=null ? d.fechaDevolucion : ''));
    var venId = (d.venta_id!=null ? d.venta_id : (d.ventaId!=null ? d.ventaId : ''));
    var cli   = (d.cliente_nombre || d.clienteNombre) || ((d.cliente_id||d.clienteId) ? ('ID ' + (d.cliente_id||d.clienteId)) : '');
    var tot   = (d.total_devolucion!=null ? d.total_devolucion : (d.totalDevolucion!=null ? d.totalDevolucion : null));
    var est   = (d.estado!=null ? d.estado : '');

    var numAttr = String(num).replace(/'/g, "\\'");
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + id + '</td>'
      + '<td>' + num + '</td>'
      + '<td>' + fec + '</td>'
      + '<td>' + venId + '</td>'
      + '<td>' + cli + '</td>'
      + '<td class="text-end">' + money(tot) + '</td>'
      + '<td>' + est + '</td>'
      + '<td class="text-end">'
      +   '<div class="btn-group btn-group-sm">'
      +     '<a class="btn btn-outline-secondary" href="' + ctx + '/devolucion_detalle.jsp?id=' + id + '">Ver</a>'
      +     '<button class="btn btn-outline-danger" onclick="abrirAnular(' + id + ', \'' + numAttr + '\')">Anular</button>'
      +   '</div>'
      + '</td>';
    tb.appendChild(tr);
  });
}

// ==== Filtros / Paginación ====
function buscar(e){
  e.preventDefault();
  var f = e.target;
  page = 0;
  last = {
    desde: f.desde.value,
    hasta: f.hasta.value,
    clienteId: f.clienteId.value,
    ventaId: f.ventaId.value
  };
  cargar(last);
}
function limpiar(){
  var form = document.getElementById('filtros');
  if(form) form.reset();
  last = {};
  page = 0;
  cargar();
}
function cambiarPagina(delta){
  page = Math.max(0, page + delta);
  cargar(last);
}

// ==== Anular ====
function abrirAnular(id, numero){
  var idEl  = document.getElementById('anularId');
  var numEl = document.getElementById('anularNum');
  if (idEl)  idEl.value = id;
  if (numEl) numEl.textContent = (numero && String(numero).length>0) ? String(numero) : String(id);
  new bootstrap.Modal(document.getElementById('modalAnular')).show();
}

async function confirmarAnular(){
  try{
    var id = document.getElementById('anularId').value;
    var url = API_DEV + '/' + id + '/anular?usuarioId=1';
    var res = await fetch(url, { method: 'POST' });
    var body = null; try{ body = await res.json(); }catch(e){}
    if(!res.ok){
      var msg = (body && (body.detail || body.error || body.message)) || ('HTTP ' + res.status);
      throw new Error(msg);
    }
    var m = bootstrap.Modal.getInstance(document.getElementById('modalAnular'));
    if (m) m.hide();
    toastOk('Devolución anulada.');
    cargar(last);
  }catch(err){
    toastErr('No se pudo anular: ' + err.message);
  }
}

// ==== Boot ====
window.addEventListener('DOMContentLoaded', function(){
  cargar();
});
</script>

</body>
</html>

