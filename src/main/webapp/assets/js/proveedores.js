(() => {
  // ================== CONFIGURACIÓN DEL API ==================
  // ⬇️ ELIGE UNA de estas dos líneas según tu despliegue:

  // 1) SPRING BOOT embebido en 8080, SIN context-path:
  const API_BASE = 'http://localhost:8080';

  // 2) (OPCIONAL) WAR en Tomcat con context-path, descomenta y ajusta:
  // const API_BASE = 'http://localhost:8080/nexttech-backend';

  // Endpoint de proveedores
  const API = `${API_BASE}/api/proveedores`;

  // ================== ELEMENTOS DEL DOM ==================
  const tbl = document.getElementById('tblProveedores');
  const pag = document.getElementById('paginacion');
  const lblResumen = document.getElementById('lblResumen');
  const qInput = document.getElementById('txtSearch');
  const chkAct = document.getElementById('chkSoloActivos');
  const btnBuscar = document.getElementById('btnBuscar');
  const btnOpenCreate = document.getElementById('btnOpenCreate');

  const mdlUpsert = new bootstrap.Modal(document.getElementById('mdlUpsert'));
  const mdlView   = new bootstrap.Modal(document.getElementById('mdlView'));
  const mdlDelete = new bootstrap.Modal(document.getElementById('mdlDelete'));
  const frm = document.getElementById('frmUpsert');

  // ================== ESTADO ==================
  let state = { page: 0, size: 10, totalPages: 0, totalElements: 0, data: [] };
  let rowToDelete = null;

  // ================== LISTADO ==================
  async function fetchList() {
    const q = qInput.value.trim();
    const activo = chkAct.checked ? 'true' : '';
    const url = `${API}?q=${encodeURIComponent(q)}&search=${encodeURIComponent(q)}&activo=${activo}&page=${state.page}&size=${state.size}`;

    try {
      const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
      if (!res.ok) throw new Error(await res.text());
      const json = await res.json();

      let items = [];
      if (Array.isArray(json)) {
        items = json;
        state.totalElements = items.length;
        state.totalPages = 1;
      } else if (json && Array.isArray(json.content)) {
        items = json.content;
        state.totalElements = json.totalElements ?? items.length;
        state.totalPages = json.totalPages ?? 1;
      } else {
        items = json.data || [];
        state.totalElements = items.length;
        state.totalPages = 1;
      }

      state.data = items;
      renderRows(items);
      renderPager();
      lblResumen.textContent = `${state.totalElements} resultado(s)`;

      if (items.length === 0) {
        tbl.innerHTML = `<tr><td colspan="11" class="text-center text-muted py-4">Sin proveedores</td></tr>`;
      }
    } catch (e) {
      tbl.innerHTML = `<tr><td colspan="11" class="text-center text-danger py-4">No se pudo cargar la lista</td></tr>`;
      ntToast({ title: 'Error', body: ntParseApiError(e.message), type: 'error' });
      console.error(e);
    }
  }

  // Orden de columnas EXACTO al JSON solicitado
  function renderRows(items) {
    tbl.innerHTML = items.map(p => `
      <tr>
        <td class="text-nowrap">${ntEsc(p.codigo)}</td>
        <td>${ntEsc(p.nombre)}</td>
        <td class="text-nowrap">${ntEsc(p.nit)}</td>
        <td>${ntEsc(p.telefono)}</td>
        <td>${ntEsc(p.direccion)}</td>
        <td>${ntEsc(p.email)}</td>
        <td>${ntEsc(p.contacto_principal)}</td>
        <td class="text-center">${p.dias_credito ?? ''}</td>
        <td>${p.activo ? '<span class="badge bg-success-subtle text-success-emphasis">Sí</span>'
                       : '<span class="badge bg-secondary">No</span>'}</td>
        <td class="text-center">${p.registrado_por ?? ''}</td>
        <td class="text-end">
          <div class="btn-group">
            <button class="btn btn-sm btn-outline-secondary" data-act="view" data-id="${p.id}" title="Ver">
              <i class="bi bi-eye"></i>
            </button>
            <button class="btn btn-sm btn-outline-primary" data-act="edit" data-id="${p.id}" title="Editar">
              <i class="bi bi-pencil"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger" data-act="del" data-id="${p.id}" data-name="${ntEsc(p.nombre)}" title="Eliminar">
              <i class="bi bi-trash"></i>
            </button>
          </div>
        </td>
      </tr>
    `).join('');
  }

  function renderPager() {
    const pages = Math.max(1, state.totalPages);
    const cur = Math.min(state.page, pages - 1);
    state.page = cur;

    let html = `
      <li class="page-item ${cur===0?'disabled':''}">
        <a href="#" class="page-link" data-pg="${cur-1}">«</a>
      </li>`;
    for (let i=0; i<pages; i++){
      html += `<li class="page-item ${i===cur?'active':''}">
                 <a href="#" class="page-link" data-pg="${i}">${i+1}</a>
               </li>`;
    }
    html += `
      <li class="page-item ${cur>=pages-1?'disabled':''}">
        <a href="#" class="page-link" data-pg="${cur+1}">»</a>
      </li>`;
    pag.innerHTML = html;
  }

  // ================== CREAR ==================
  function openCreate() {
    frm.reset();
    frm.classList.remove('was-validated');
    setFormValues({ activo: true });
    document.getElementById('mdlUpsertTitle').innerHTML = `<i class="bi bi-plus-circle"></i> Nuevo proveedor`;
    mdlUpsert.show();
  }

  // ================== EDITAR (abre modal y carga datos) ==================
  async function openEdit(id) {
    const local = state.data.find(x => String(x.id) === String(id));
    if (local) {
      setFormValues(local);
      document.getElementById('mdlUpsertTitle').innerHTML = `<i class="bi bi-pencil-square"></i> Editar proveedor`;
      return void mdlUpsert.show();
    }
    try {
      const res = await fetch(`${API}/${id}`);
      if (!res.ok) throw new Error(await res.text());
      const p = await res.json();
      setFormValues(p);
      document.getElementById('mdlUpsertTitle').innerHTML = `<i class="bi bi-pencil-square"></i> Editar proveedor`;
      mdlUpsert.show();
    } catch (e) {
      ntToast({ title:'Error', body:'No se pudo cargar el proveedor.', type:'error' });
    }
  }

  function setFormValues(p = {}) {
    g('prov_id').value = p.id ?? '';
    g('prov_codigo').value = p.codigo ?? '';
    g('prov_nombre').value = p.nombre ?? '';
    g('prov_nit').value = p.nit ?? '';
    g('prov_telefono').value = p.telefono ?? '';
    g('prov_dias_credito').value = p.dias_credito ?? 0;
    g('prov_direccion').value = p.direccion ?? '';
    g('prov_email').value = p.email ?? '';
    g('prov_contacto_principal').value = p.contacto_principal ?? '';
    g('prov_registrado_por').value = p.registrado_por ?? '';
    g('prov_activo').checked = p.activo ?? true;
  }

  function getFormValues() {
    return {
      id: g('prov_id').value || null,
      codigo: g('prov_codigo').value.trim(),
      nombre: g('prov_nombre').value.trim(),
      nit: g('prov_nit').value.trim(),
      telefono: g('prov_telefono').value.trim(),
      direccion: g('prov_direccion').value.trim() || null,
      email: g('prov_email').value.trim() || null,
      contacto_principal: g('prov_contacto_principal').value.trim() || null,
      dias_credito: Number(g('prov_dias_credito').value || 0),
      activo: g('prov_activo').checked,
      registrado_por: Number(g('prov_registrado_por').value)
    };
  }

  // ================== SUBMIT (crear/editar) ==================
  async function submitUpsert(e) {
    e.preventDefault();
    e.stopPropagation();
    frm.classList.add('was-validated');
    if (!frm.checkValidity()) return;

    const payload = getFormValues();
    const isEdit = !!payload.id;
    const method = isEdit ? 'PUT' : 'POST';
    const url = isEdit ? `${API}/${payload.id}` : API;

    try {
      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!res.ok) throw new Error(await res.text());
      mdlUpsert.hide();
      ntToast({ title:'Éxito', body:`Proveedor ${isEdit ? 'actualizado' : 'creado'} correctamente.`, type:'success' });
      await fetchList();
    } catch (e) {
      ntToast({ title:'Error', body: ntParseApiError(e.message), type:'error' });
    }
  }

  // ================== VER ==================
  function openView(id) {
    const p = state.data.find(x => String(x.id) === String(id));
    if (!p) return;
    const dl = document.getElementById('viewContent');
    dl.innerHTML = `
      ${row('Código', p.codigo)}
      ${row('Nombre', p.nombre)}
      ${row('NIT', p.nit)}
      ${row('Teléfono', p.telefono)}
      ${row('Dirección', p.direccion)}
      ${row('Email', p.email)}
      ${row('Contacto principal', p.contacto_principal)}
      ${row('Días crédito', p.dias_credito)}
      ${row('Activo', p.activo ? 'Sí' : 'No')}
      ${row('Registrado por', p.registrado_por)}
    `;
    mdlView.show();
  }

  // ================== ELIMINAR ==================
  function openDelete(id, name) {
    rowToDelete = { id, name };
    document.getElementById('delNombre').textContent = name;
    mdlDelete.show();
  }
  async function confirmDelete() {
    if (!rowToDelete) return;
    try {
      const res = await fetch(`${API}/${rowToDelete.id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error(await res.text());
      mdlDelete.hide();
      ntToast({ title:'Eliminado', body:`${rowToDelete.name} fue dado de baja.`, type:'success' });
      await fetchList();
    } catch (e) {
      ntToast({ title:'Error', body: ntParseApiError(e.message), type:'error' });
    }
  }

  // ================== EVENTOS ==================
  btnBuscar.addEventListener('click', () => { state.page = 0; fetchList(); });
  btnOpenCreate.addEventListener('click', openCreate);
  pag.addEventListener('click', e => {
    const a = e.target.closest('a[data-pg]');
    if (!a) return;
    e.preventDefault();
    state.page = Number(a.dataset.pg);
    fetchList();
  });
  tbl.addEventListener('click', e => {
    const btn = e.target.closest('button[data-act]');
    if (!btn) return;
    const id = btn.dataset.id, act = btn.dataset.act;
    if (act === 'view') openView(id);
    if (act === 'edit') openEdit(id);     // abre modal con datos
    if (act === 'del')  openDelete(id, btn.dataset.name);
  });
  frm.addEventListener('submit', submitUpsert);
  document.getElementById('btnConfirmDelete').addEventListener('click', confirmDelete);

  // ================== HELPERS ==================
  function g(id){ return document.getElementById(id); }
  function row(label, val){ return `<dt class="col-5">${ntEsc(label)}</dt><dd class="col-7">${ntEsc(String(val ?? ''))}</dd>`; }

  // ================== INIT ==================
  tbl.innerHTML = `<tr><td colspan="11" class="text-center text-muted py-4"><div class="spinner-border spinner-border-sm me-2"></div>Cargando...</td></tr>`;
  fetchList();
})();
