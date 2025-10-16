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
    <div class="d-flex gap-2">
      <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/ventas.jsp">&laquo; Volver</a>
      <button class="btn btn-primary" id="btnEditarCab" data-bs-toggle="modal" data-bs-target="#modalEditarCab">Editar cabecera</button>
      <button class="btn btn-outline-primary" id="btnAgregarItem" data-bs-toggle="modal" data-bs-target="#modalAgregarItem">Agregar ítem</button>
      <button class="btn btn-outline-danger" id="btnEliminarVenta">Eliminar venta</button>
    </div>
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
          <th class="text-end">Acciones</th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>

<!-- Modal Editar Cabecera -->
<div class="modal fade" id="modalEditarCab" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <form id="formCab" onsubmit="guardarCabecera(event)">
        <div class="modal-header">
          <h5 class="modal-title">Editar cabecera de venta</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Tipo de Pago</label>
              <select class="form-select" name="tipoPago">
                <option value="C">Contado</option>
                <option value="R">Crédito</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Vendedor</label>
              <select id="selVendedor" class="form-select" name="vendedorId"></select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Cajero</label>
              <select id="selCajero" class="form-select" name="cajeroId"></select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Bodega Origen</label>
              <select id="selBodega" class="form-select" name="bodegaOrigenId"></select>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <input type="text" class="form-control" name="observaciones" maxlength="255">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn btn-primary">Guardar cambios</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Modal Agregar Ítem -->
<div class="modal fade" id="modalAgregarItem" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <form id="formItem" onsubmit="guardarItem(event)">
        <div class="modal-header">
          <h5 class="modal-title">Agregar ítem</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Bodega *</label>
              <select id="itBodega" class="form-select" required></select>
            </div>
            <div class="col-md-5">
              <label class="form-label">Producto *</label>
              <select id="itProducto" class="form-select" required disabled>
                <option value="">Seleccione bodega...</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Stock</label>
              <div class="form-control" id="itStock" readonly>0</div>
            </div>
            <div class="col-md-3">
              <label class="form-label">Cantidad *</label>
              <input id="itCantidad" type="number" min="0.01" step="0.01" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">Precio Unitario *</label>
              <input id="itPrecio" type="number" min="0" step="0.01" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">Descuento</label>
              <input id="itDesc" type="number" min="0" step="0.01" class="form-control">
            </div>
            <div class="col-md-3">
              <label class="form-label">Lote</label>
              <input id="itLote" type="text" class="form-control" placeholder="S/N">
            </div>
            <div class="col-md-3">
              <label class="form-label">Vence</label>
              <input id="itVence" type="date" class="form-control">
            </div>
          </div>
          <div class="form-text mt-2">Campos con * son obligatorios.</div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn btn-primary">Agregar</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
// === Config/ENDPOINTS (ajusta si tu API usa otros nombres) ===
const API_BASE = 'http://localhost:8080/api/ventas';
const API_CAT  = 'http://localhost:8080/api/catalogos';
const CTX      = '${pageContext.request.contextPath}';

// === Estado ===
var ventaActual = null;

// === Utils ===
function qs(name){ var u = new URL(window.location.href); return u.searchParams.get(name); }
function formatMoney(n){
  if(n==null || n==='' || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
function val(x){ return (x===undefined || x===null) ? '' : String(x); }
async function fetchJson(url, opts){
  const res = await fetch(url, opts);
  const txt = await res.text();
  let data = null;
  try{ data = txt ? JSON.parse(txt) : null; }catch{}
  if(!res.ok) throw new Error((data && (data.error||data.detail)) || ('HTTP '+res.status));
  return data;
}

// === Render header y detalle ===
function renderCabecera(v){
  var cliente = (v && v.clienteNombre && String(v.clienteNombre).trim()!=='')
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
      + '<td>' + val(d && d.fechaVencimiento) + '</td>'
      + '<td class="text-end">'
      +   '<button class="btn btn-sm btn-outline-danger" onclick="eliminarLinea(' + val(d && d.id) + ')">Eliminar</button>'
      + '</td>';
    tbody.appendChild(tr);
  });
}

// === Carga inicial ===
async function cargar(){
  try{
    var id = qs('id');
    if(!id) throw new Error('Falta parámetro ?id=');
    const venta = await fetchJson(API_BASE + '/' + id);
    ventaActual = venta;
    renderCabecera(venta);
    renderDetalles(venta && venta.items);
    // Pre-cargar catálogos para modales
    await cargarCatalogosCab();
    await cargarBodegas();
  }catch(err){
    console.error(err);
    document.getElementById('cabecera').innerHTML =
      '<div class="alert alert-danger">Error: ' + (err.message || 'desconocido') + '</div>';
  }
}

// === Catálogos para modales ===
async function cargarCatalogosCab(){
  try{
    const emp = await fetchJson(API_CAT + '/empleados?limit=100');
    const bod = await fetchJson(API_CAT + '/bodegas?limit=100');
    fillSelect(document.getElementById('selVendedor'), emp, function(e){ return {value:e.id, text:(e.codigo||('EMP-'+e.id))+' - '+(e.nombres||'')+' '+(e.apellidos||'')}} );
    fillSelect(document.getElementById('selCajero'),   emp, function(e){ return {value:e.id, text:(e.codigo||('EMP-'+e.id))+' - '+(e.nombres||'')+' '+(e.apellidos||'')}} );
    fillSelect(document.getElementById('selBodega'),   bod, function(b){ return {value:b.id, text:(b.nombre || ('Bodega '+b.id))}} );
    // set defaults desde la venta
    var f = document.getElementById('formCab');
    if(ventaActual){
      f.tipoPago.value = ventaActual.tipoPago || 'C';
      if(ventaActual.vendedorId) f.vendedorId.value = ventaActual.vendedorId;
      if(ventaActual.cajeroId)   f.cajeroId.value   = ventaActual.cajeroId;
      if(ventaActual.bodegaOrigenId) f.bodegaOrigenId.value = ventaActual.bodegaOrigenId;
      f.observaciones.value = ventaActual.observaciones || '';
    }
  }catch(e){ console.warn('Catálogos cabecera:', e); }
}
async function cargarBodegas(){
  try{
    const bod = await fetchJson(API_CAT + '/bodegas?limit=100');
    fillSelect(document.getElementById('itBodega'), bod, function(b){ return {value:b.id, text:(b.nombre || ('Bodega '+b.id))}} );
  }catch(e){ console.warn('Catálogo bodegas:', e); }
}
function fillSelect(sel, data, map){
  var html = '<option value="">Seleccione...</option>';
  (Array.isArray(data)?data:[]).forEach(function(x){
    var o = map(x); html += '<option value="'+o.value+'">'+o.text+'</option>';
  });
  sel.innerHTML = html;
}

// === Editar cabecera ===
async function guardarCabecera(e){
  e.preventDefault();
  try{
    var id = ventaActual && ventaActual.id;
    if(!id) throw new Error('Venta no cargada');

    var f = e.target;
    var payload = {
      tipoPago: f.tipoPago.value || null,
      vendedorId: f.vendedorId.value ? Number(f.vendedorId.value) : null,
      cajeroId:   f.cajeroId.value   ? Number(f.cajeroId.value)   : null,
      bodegaOrigenId: f.bodegaOrigenId.value ? Number(f.bodegaOrigenId.value) : null,
      observaciones: f.observaciones.value || null
    };

    await fetchJson(API_BASE + '/' + id, {
      method:'PUT',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });

    // refrescar
    const modal = bootstrap.Modal.getInstance(document.getElementById('modalEditarCab'));
    modal.hide();
    await cargar();
  }catch(err){
    alert('No se pudo guardar la cabecera: ' + (err.message||''));
  }
}

// === Agregar ítem ===
document.getElementById('itBodega').addEventListener('change', async function(){
  var bodId = this.value;
  var selProd = document.getElementById('itProducto');
  var stock = document.getElementById('itStock');
  selProd.disabled = true; selProd.innerHTML = '<option value="">Cargando...</option>';
  stock.innerText = '0';
  if(!bodId){ selProd.disabled = false; selProd.innerHTML = '<option value="">Seleccione bodega...</option>'; return; }
  try{
    const prods = await fetchJson(API_CAT + '/productos?bodegaId=' + encodeURIComponent(bodId));
    var html = '<option value="">Seleccione...</option>';
    (Array.isArray(prods)?prods:[]).forEach(function(p){
      var st = p.stockDisponible || 0;
      var pr = p.precioSugerido || 0;
      html += '<option value="'+p.id+'" data-stock="'+st+'" data-precio="'+pr+'">'+ (p.nombre || ('Producto '+p.id)) +' (stock '+st+')</option>';
    });
    selProd.innerHTML = html;
    selProd.disabled = false;
  }catch{ selProd.disabled=false; selProd.innerHTML = '<option value="">(sin datos)</option>'; }
});
document.getElementById('itProducto').addEventListener('change', function(){
  var opt = this.selectedOptions[0];
  var stock = document.getElementById('itStock');
  var precio = document.getElementById('itPrecio');
  if(!opt){ stock.innerText='0'; return; }
  var st = Number(opt.getAttribute('data-stock')||0);
  var pr = Number(opt.getAttribute('data-precio')||0);
  stock.innerText = String(st);
  if(pr>0) precio.value = pr;
});

async function guardarItem(e){
  e.preventDefault();
  try{
    var id = ventaActual && ventaActual.id;
    if(!id) throw new Error('Venta no cargada');

    var payload = {
      productoId: Number(document.getElementById('itProducto').value),
      bodegaId: Number(document.getElementById('itBodega').value),
      cantidad: Number(document.getElementById('itCantidad').value),
      precioUnitario: Number(document.getElementById('itPrecio').value),
      descuento: document.getElementById('itDesc').value ? Number(document.getElementById('itDesc').value) : null,
      lote: document.getElementById('itLote').value || null,
      fechaVencimiento: document.getElementById('itVence').value || null
    };

    await fetchJson(API_BASE + '/' + id + '/items', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });

    const modal = bootstrap.Modal.getInstance(document.getElementById('modalAgregarItem'));
    modal.hide();
    await cargar();
  }catch(err){
    alert('No se pudo agregar el ítem: ' + (err.message||''));
  }
}

// === Eliminar línea ===
async function eliminarLinea(detalleId){
  if(!confirm('¿Eliminar la línea '+detalleId+'?')) return;
  try{
    var id = ventaActual && ventaActual.id;
    await fetchJson(API_BASE + '/' + id + '/items/' + detalleId, { method:'DELETE' });
    await cargar();
  }catch(err){
    alert('No se pudo eliminar la línea: ' + (err.message||''));
  }
}

// === Eliminar/Anular venta ===
document.getElementById('btnEliminarVenta').addEventListener('click', async function(){
  if(!ventaActual || !ventaActual.id) return;
  if(!confirm('¿Eliminar la venta #' + ventaActual.id + ' (' + (ventaActual.numeroVenta||'') + ')?')) return;
  try{
    await fetchJson(API_BASE + '/' + ventaActual.id, { method:'DELETE' });
    // regresar al listado
    window.location.href = CTX + '/ventas.jsp';
  }catch(err){
    alert('No se pudo eliminar la venta: ' + (err.message||''));
  }
});

// === Boot ===
window.addEventListener('DOMContentLoaded', cargar);
</script>
</body>
</html>
