<%-- 
    Document   : cxc
    Created on : 15/10/2025, 20:28:31
    Author     : rodri
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Cuentas por Cobrar | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-ui">
</head>
<body>
<div class="container py-4">
  <h2 class="mb-3">Cuentas por Cobrar</h2>

  <div class="card mb-3">
    <div class="card-body">
      <form id="filtros" onsubmit="buscar(event)" class="row g-3">
        <div class="col-md-3">
          <label class="form-label">Desde</label>
          <input type="date" name="desde" class="form-control">
        </div>
        <div class="col-md-3">
          <label class="form-label">Hasta</label>
          <input type="date" name="hasta" class="form-control">
        </div>
        <div class="col-md-3">
          <label class="form-label">Cliente ID</label>
          <input type="number" min="1" name="clienteId" placeholder="Ej. 1" class="form-control">
        </div>
        <div class="col-md-3">
          <label class="form-label">Estado</label>
          <select name="estado" class="form-select">
            <option value="">(Todos)</option>
            <option value="P">Pendiente</option>
            <option value="C">Cancelado</option>
          </select>
        </div>
        <div class="col-12 d-flex gap-2 justify-content-end">
          <button class="btn btn-primary" type="submit">Buscar</button>
          <button class="btn btn-outline-secondary" type="button" onclick="limpiar()">Limpiar</button>
        </div>
      </form>
      <div id="errorBox" class="alert alert-danger mt-3 d-none"></div>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="d-flex align-items-center gap-2">
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(-1)">&laquo; Anterior</button>
      <div> Página <span id="pActual">1</span> </div>
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(1)">Siguiente &raquo;</button>
    </div>
    <small class="text-muted">Mostrando 10 por página</small>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table id="tabla" class="table table-striped table-hover align-middle mb-0">
        <thead>
        <tr>
          <th>ID</th>
          <th>Documento</th>
          <th>Fecha</th>
          <th>Cliente</th>
          <th class="text-end">Monto</th>
          <th class="text-end">Saldo</th>
          <th>Estado</th>
          <th class="text-end">Acciones</th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
    <div id="tablaEmpty" class="p-3 text-muted d-none">Sin resultados para los filtros actuales.</div>
  </div>
</div>

<script>
// ==== Config ====
const API_DOCS = 'http://localhost:8080/api/cxc/documentos';
let page = 0, size = 10, last = {};

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
function showError(msg){
  var box = document.getElementById('errorBox');
  if(!box) return;
  if(!msg){ box.classList.add('d-none'); box.textContent=''; return; }
  box.textContent = 'Error al llamar ' + msg;
  box.classList.remove('d-none');
}

// ==== Core ====
async function cargar(params){
  params = params || {};
  try{
    var qs = new URLSearchParams({ page: page, size: size });
    if(params.desde)     qs.set('desde', params.desde);
    if(params.hasta)     qs.set('hasta', params.hasta);
    if(params.clienteId) qs.set('clienteId', params.clienteId);
    if(params.estado)    qs.set('estado', params.estado);

    var data = await fetchJson(API_DOCS + '?' + qs.toString());
    render(toArr(data));
    var pEl = document.getElementById('pActual'); if(pEl) pEl.textContent = (page+1);
    showError(null);
  }catch(err){
    var base = 'http://localhost:8080/api/cxc/documentos?' + new URLSearchParams({ page: page, size: size }).toString() + ': ' + err.message;
    showError(base);
    render([]);
  }
}

function render(rows){
  var tb = document.querySelector('#tabla tbody');
  var empty = document.getElementById('tablaEmpty');
  tb.innerHTML = '';
  if(!rows.length){ if(empty) empty.classList.remove('d-none'); return; }
  if(empty) empty.classList.add('d-none');

  rows.forEach(function(x){
    var id    = (x.id!=null ? x.id : (x.documento_id!=null ? x.documento_id : ''));
    var num   = (x.numero!=null ? x.numero : (x.numero_documento!=null ? x.numero_documento : (x.documento || '')));
    var fec   = (x.fecha!=null ? x.fecha : (x.fecha_emision!=null ? x.fecha_emision : ''));
    var cli   = (x.clienteNombre || x.cliente_nombre) || ((x.clienteId||x.cliente_id) ? ('ID ' + (x.clienteId||x.cliente_id)) : '');
    var monto = (x.monto!=null ? x.monto : (x.monto_total!=null ? x.monto_total : (x.total!=null ? x.total : null)));
    var saldo = (x.saldo!=null ? x.saldo : (x.saldoPendiente!=null ? x.saldoPendiente : (x.saldo_pendiente!=null ? x.saldo_pendiente : null)));
    var est   = (x.estado!=null ? x.estado : 'P');

    var numSafe = String(num);
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + id + '</td>'
      + '<td>' + numSafe + '</td>'
      + '<td>' + fec + '</td>'
      + '<td>' + cli + '</td>'
      + '<td class="text-end">' + money(monto) + '</td>'
      + '<td class="text-end">' + money(saldo) + '</td>'
      + '<td>' + est + '</td>'
      + '<td class="text-end">'
      +   '<div class="btn-group btn-group-sm">'
      +     '<button class="btn btn-outline-primary" onclick="abrirPago(' + id + ', \'' + numSafe.replace(/'/g, "\\'") + '\')">Registrar pago</button>'
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
    estado: f.estado.value
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

// ==== Pagos (placeholder simple) ====
function abrirPago(id, numero){
  // Aquí luego conectas tu modal real de pagos
  alert('Registrar pago para documento ' + numero + ' (ID ' + id + ')');
}

// ==== Boot ====
window.addEventListener('DOMContentLoaded', function(){
  cargar();
});
</script>

</body>
</html>
