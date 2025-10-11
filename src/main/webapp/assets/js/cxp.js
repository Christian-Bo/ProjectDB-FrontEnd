// assets/js/cxp.js
// UI para CxP: documentos, pagos y aplicaciones.

(function () {
  const q = (s, r=document) => r.querySelector(s);
  const qa = (s, r=document) => Array.from(r.querySelectorAll(s));

  // ---------- DOCUMENTOS ----------
  const $docFiltroProv = q('#doc-proveedor');
  const $docFiltroTxt  = q('#doc-texto');
  const $docBuscar     = q('#doc-buscar');
  const $docTbody      = q('#doc-tbody');
  const $docNuevo      = q('#doc-nuevo');

  const $docModal = new bootstrap.Modal('#modalDoc');
  const $docForm  = q('#form-doc');
  const $docId    = q('#doc-id');
  const $proveedor_id = q('#proveedor_id');
  const $origen_tipo  = q('#origen_tipo');
  const $origen_id    = q('#origen_id');
  const $numero_documento = q('#numero_documento');
  const $fecha_emision = q('#fecha_emision');
  const $fecha_vencimiento = q('#fecha_vencimiento');
  const $moneda       = q('#moneda');
  const $monto_total  = q('#monto_total');

  async function docListar() {
    const prov = $docFiltroProv.value.trim() || null;
    const txt  = $docFiltroTxt.value.trim() || null;
    const qs = [];
    if (prov) qs.push(`proveedorId=${encodeURIComponent(prov)}`);
    if (txt)  qs.push(`texto=${encodeURIComponent(txt)}`);
    try {
      const rows = await API.request(`/api/cxp/documentos${qs.length?`?${qs.join('&')}`:''}`);
      renderDocs(rows || []);
    } catch (e) {
      API.toast(`Error listando documentos: ${e.message}`, 'danger');
    }
  }

  function renderDocs(rows) {
    $docTbody.innerHTML = rows.length ? '' : `<tr><td colspan="10" class="text-center text-muted">Sin documentos</td></tr>`;
    for (const r of rows) {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${r.id}</td>
        <td>${r.proveedor_id}</td>
        <td>${r.origen_tipo}-${r.origen_id}</td>
        <td>${r.numero_documento}</td>
        <td>${r.fecha_emision}</td>
        <td>${r.fecha_vencimiento ?? ''}</td>
        <td>${r.moneda}</td>
        <td class="text-end">Q ${Number(r.monto_total).toFixed(2)}</td>
        <td class="text-end">Q ${Number(r.saldo_pendiente).toFixed(2)}</td>
        <td>
          <div class="d-flex justify-content-end gap-2">
            <button class="btn btn-sm btn-outline-secondary btn-doc-edit" data-id="${r.id}"><i class="bi bi-pencil"></i></button>
            <button class="btn btn-sm btn-outline-danger btn-doc-anular" data-id="${r.id}"><i class="bi bi-x-circle"></i></button>
          </div>
        </td>`;
      $docTbody.appendChild(tr);
    }
    qa('.btn-doc-edit').forEach(b=>b.addEventListener('click', onDocEditar));
    qa('.btn-doc-anular').forEach(b=>b.addEventListener('click', onDocAnular));
  }

  function abrirDocNuevo() {
    $docForm.reset();
    $docId.value = '';
    q('#modalDocLabel').textContent = 'Nuevo documento CxP';
    // campos editables completos al crear
    $proveedor_id.disabled = false; $origen_tipo.disabled = false; $origen_id.disabled = false;
    $docModal.show();
  }

  function abrirDocEditar(row) {
    $docForm.reset();
    $docId.value = row.id;
    $proveedor_id.value = row.proveedor_id;
    $origen_tipo.value = row.origen_tipo;
    $origen_id.value = row.origen_id;
    $numero_documento.value = row.numero_documento;
    $fecha_emision.value = row.fecha_emision;
    $fecha_vencimiento.value = row.fecha_vencimiento || '';
    $moneda.value = row.moneda;
    $monto_total.value = row.monto_total;
    q('#modalDocLabel').textContent = `Editar documento #${row.id}`;
    // proveedor/origen no se editan
    $proveedor_id.disabled = true; $origen_tipo.disabled = true; $origen_id.disabled = true;
    $docModal.show();
  }

  function extraerDocDeFila(btn) {
    const tr = btn.closest('tr');
    return {
      id: Number(btn.dataset.id),
      proveedor_id: Number(tr.children[1].textContent),
      origen_tipo: tr.children[2].textContent.split('-')[0],
      origen_id: Number(tr.children[2].textContent.split('-')[1]),
      numero_documento: tr.children[3].textContent,
      fecha_emision: tr.children[4].textContent,
      fecha_vencimiento: tr.children[5].textContent || null,
      moneda: tr.children[6].textContent,
      monto_total: tr.children[7].textContent.replace(/[^\d.]/g,'')
    };
  }

  async function onDocEditar(ev){
    const row = extraerDocDeFila(ev.currentTarget);
    abrirDocEditar(row);
  }

  async function onDocAnular(ev){
    const id = Number(ev.currentTarget.dataset.id);
    if (!confirm(`¿Anular documento #${id}?`)) return;
    try {
      await API.request(`/api/cxp/documentos/${id}/anular`, { method: 'DELETE' });
      API.toast('Documento anulado.', 'success');
      docListar();
    } catch(e){ API.toast(`Error: ${e.message}`, 'danger'); }
  }

  async function onDocSubmit(ev) {
    ev.preventDefault();
    const id = $docId.value ? Number($docId.value) : null;
    const isEdit = !!id;
    try {
      if (!isEdit) {
        const payload = {
          proveedor_id: Number($proveedor_id.value),
          origen_tipo: $origen_tipo.value,
          origen_id: Number($origen_id.value),
          numero_documento: $numero_documento.value.trim(),
          fecha_emision: $fecha_emision.value,
          fecha_vencimiento: $fecha_vencimiento.value || null,
          moneda: $moneda.value,
          monto_total: Number($monto_total.value)
        };
        await API.request('/api/cxp/documentos', { method: 'POST', json: payload });
        API.toast('Documento creado.', 'success');
      } else {
        const payload = {
          numero_documento: $numero_documento.value.trim(),
          fecha_emision: $fecha_emision.value,
          fecha_vencimiento: $fecha_vencimiento.value || null,
          moneda: $moneda.value,
          monto_total: Number($monto_total.value)
        };
        await API.request(`/api/cxp/documentos/${id}`, { method: 'PUT', json: payload });
        API.toast('Documento actualizado.', 'success');
      }
      $docModal.hide();
      docListar();
    } catch(e){ API.toast(`Error guardando: ${e.message}`, 'danger'); }
  }

  // ---------- PAGOS ----------
  const $pagFiltroProv = q('#pag-proveedor');
  const $pagFiltroTxt  = q('#pag-texto');
  const $pagBuscar     = q('#pag-buscar');
  const $pagTbody      = q('#pag-tbody');
  const $pagNuevo      = q('#pag-nuevo');

  const $pagModal = new bootstrap.Modal('#modalPagoCxp');
  const $pagForm  = q('#form-pago-cxp');
  const $pago_id  = q('#pago_id'); // hidden para editar
  const $_proveedor_id = q('#p_proveedor_id');
  const $fecha_pago = q('#fecha_pago');
  const $forma_pago = q('#p_forma_pago');
  const $_monto_total = q('#p_monto_total');
  const $observaciones = q('#observaciones');

  async function pagListar(){
    const prov = $pagFiltroProv.value.trim() || null;
    const txt = $pagFiltroTxt.value.trim() || null;
    const qs = [];
    if (prov) qs.push(`proveedorId=${encodeURIComponent(prov)}`);
    if (txt) qs.push(`texto=${encodeURIComponent(txt)}`);
    try {
      const rows = await API.request(`/api/cxp/pagos${qs.length?`?${qs.join('&')}`:''}`);
      renderPagos(rows||[]);
    } catch(e){ API.toast(`Error listando pagos: ${e.message}`, 'danger'); }
  }

  function renderPagos(rows) {
    $pagTbody.innerHTML = rows.length ? '' : `<tr><td colspan="8" class="text-center text-muted">Sin pagos</td></tr>`;
    for (const r of rows) {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${r.id}</td>
        <td>${r.proveedor_id}</td>
        <td>${r.fecha_pago}</td>
        <td>${r.forma_pago}</td>
        <td class="text-end">Q ${Number(r.monto_total).toFixed(2)}</td>
        <td>${r.observaciones ?? ''}</td>
        <td class="text-end">
          <div class="btn-group">
            <button class="btn btn-sm btn-outline-secondary btn-pag-edit" data-id="${r.id}"><i class="bi bi-pencil"></i></button>
            <button class="btn btn-sm btn-outline-danger btn-pag-del" data-id="${r.id}"><i class="bi bi-trash"></i></button>
          </div>
        </td>
        <td class="text-end">
          <a class="btn btn-sm btn-outline-primary" href="#aplicaciones" data-pago="${r.id}" onclick="document.getElementById('apl-pago-id').value='${r.id}';document.getElementById('tab-aplicaciones').click();"><i class="bi bi-arrow-right-circle"></i> Aplicar</a>
        </td>`;
      $pagTbody.appendChild(tr);
    }
    qa('.btn-pag-edit').forEach(b=>b.addEventListener('click', onPagEditar));
    qa('.btn-pag-del').forEach(b=>b.addEventListener('click', onPagEliminar));
  }

  function abrirPagNuevo(){
    $pagForm.reset();
    $pago_id.value = '';
    $_proveedor_id.disabled = false;
    $pagModal.show();
  }

  function onPagEditar(ev){
    const tr = ev.currentTarget.closest('tr');
    $pagForm.reset();
    $pago_id.value = ev.currentTarget.dataset.id;
    $_proveedor_id.value = tr.children[1].textContent.trim();
    $fecha_pago.value = tr.children[2].textContent.trim();
    $forma_pago.value = tr.children[3].textContent.trim();
    $_monto_total.value = tr.children[4].textContent.replace(/[^\d.]/g,'');
    $observaciones.value = tr.children[5].textContent.trim();
    $_proveedor_id.disabled = true; // no editamos proveedor en update
    $pagModal.show();
  }

  async function onPagEliminar(ev){
    const id = Number(ev.currentTarget.dataset.id);
    if (!confirm(`¿Eliminar pago #${id}?`)) return;
    try {
      await API.request(`/api/cxp/pagos/${id}`, { method: 'DELETE' });
      API.toast('Pago eliminado.', 'success');
      pagListar();
    } catch(e){ API.toast(`Error: ${e.message}`, 'danger'); }
  }

  async function onPagSubmit(ev){
    ev.preventDefault();
    const id = $pago_id.value ? Number($pago_id.value) : null;
    try{
      if (!id) {
        const payload = {
          proveedor_id: Number($_proveedor_id.value),
          fecha_pago: $fecha_pago.value,
          forma_pago: $forma_pago.value,
          monto_total: Number($_monto_total.value),
          observaciones: $observaciones.value || null
        };
        await API.request('/api/cxp/pagos', { method: 'POST', json: payload });
        API.toast('Pago creado.', 'success');
      } else {
        const payload = {
          fecha_pago: $fecha_pago.value,
          forma_pago: $forma_pago.value,
          monto_total: Number($_monto_total.value),
          observaciones: $observaciones.value || null
        };
        await API.request(`/api/cxp/pagos/${id}`, { method: 'PUT', json: payload });
        API.toast('Pago actualizado.', 'success');
      }
      $pagModal.hide();
      pagListar();
    } catch(e){ API.toast(`Error guardando: ${e.message}`, 'danger'); }
  }

  // ---------- APLICACIONES ----------
  const $aplPagoId = q('#apl-pago-id');
  const $aplList   = q('#apl-tbody');
  const $aplForm   = q('#form-apl');
  const $aplItems  = q('#apl-items'); // textarea simple: documento_id;monto por línea
  const $aplCargar = q('#apl-cargar');

  async function aplListar(){
    const pagoId = Number($aplPagoId.value);
    if (!pagoId) { $aplList.innerHTML = `<tr><td colspan="5" class="text-center text-muted">Seleccione un pago</td></tr>`; return; }
    try {
      const rows = await API.request(`/api/cxp/pagos/${pagoId}/aplicaciones`);
      $aplList.innerHTML = rows.length ? '' : `<tr><td colspan="5" class="text-center text-muted">Sin aplicaciones</td></tr>`;
      for (const r of rows) {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td class="text-muted">#${r.id}</td>
          <td>${r.pago_id}</td>
          <td>${r.documento_id}</td>
          <td class="text-end">Q ${Number(r.monto_aplicado).toFixed(2)}</td>
          <td>${r.fecha_aplicacion ?? ''}</td>`;
        $aplList.appendChild(tr);
      }
    } catch(e){ API.toast(`Error listando aplicaciones: ${e.message}`, 'danger'); }
  }

  function parseItems(txt){
    // Formato: una línea por item -> documento_id ; monto
    // ej:
    // 3001; 950.00
    // 3002; 250
    const items = [];
    txt.split(/\r?\n/).forEach(line=>{
      const t = line.trim(); if (!t) return;
      const [doc, mon] = t.split(/[;,]/).map(s=>s.trim());
      const documento_id = Number(doc);
      const monto_aplicado = Number(mon);
      if (Number.isFinite(documento_id) && Number.isFinite(monto_aplicado)) {
        items.push({ documento_id, monto_aplicado });
      }
    });
    return items;
  }

  async function onAplSubmit(ev){
    ev.preventDefault();
    const pagoId = Number($aplPagoId.value);
    const items = parseItems($aplItems.value);
    if (!pagoId) return API.toast('Seleccione un pago', 'warning');
    if (!items.length) return API.toast('No hay items válidos', 'warning');
    try {
      await API.request(`/api/cxp/pagos/${pagoId}/aplicaciones`, { method:'POST', json:{ items }});
      API.toast('Aplicaciones creadas.', 'success');
      aplListar();
    } catch(e){ API.toast(`Error aplicando: ${e.message}`, 'danger'); }
  }

  // eventos
  $docBuscar.addEventListener('click', docListar);
  $docNuevo.addEventListener('click', abrirDocNuevo);
  $docForm.addEventListener('submit', onDocSubmit);

  $pagBuscar.addEventListener('click', pagListar);
  $pagNuevo.addEventListener('click', abrirPagNuevo);
  $pagForm.addEventListener('submit', onPagSubmit);

  $aplCargar.addEventListener('click', aplListar);
  $aplForm.addEventListener('submit', onAplSubmit);

  // init
  docListar(); pagListar(); // pestañas inician con datos
})();
