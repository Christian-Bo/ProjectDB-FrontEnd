/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */



(function (global) {
  const { baseUrl, http, showToast, loadDashboardKPIs, loadDepartamentosCatalog, loadPuestosCatalog, loadEmpleadosPageForJefes, renderPagination } = global.NT;

  let empPage = 0, empSize = 10, empSort = 'id,desc';

  // ====== UI binds ======
  function bindToolbar() {
    const btnBuscar = document.getElementById('btnEmpBuscar');
    if (btnBuscar) btnBuscar.addEventListener('click', () => { empPage = 0; loadEmpleados(); });

    const depSel = document.getElementById('empDepto');
    if (depSel) depSel.addEventListener('change', async (e) => {
      const depId = e.target.value || null;
      const puestos = await loadPuestosCatalog(depId);
      renderPuestosOptions(document.getElementById('empPuesto'), puestos, true);
    });

    const btnNuevo = document.getElementById('btnEmpNuevo');
    if (btnNuevo) btnNuevo.addEventListener('click', openModalNuevo);
  }

  // ====== Catálogos a selects ======
  function renderDeptosOptions(select, list, keepFirst = false) {
    if (!select) return;
    const prev = keepFirst ? select.innerHTML : '';
    select.innerHTML = prev || '';
    if (!keepFirst) {
      const op0 = document.createElement('option'); op0.value = ''; op0.textContent = 'Departamento'; select.appendChild(op0);
    }
    list.forEach(d => {
      const o = document.createElement('option');
      o.value = d.id; o.textContent = d.nombre; select.appendChild(o);
    });
  }
  function renderPuestosOptions(select, list, keepFirst = false) {
    if (!select) return;
    const prev = keepFirst ? select.innerHTML : '';
    select.innerHTML = prev || '';
    if (!keepFirst) {
      const op0 = document.createElement('option'); op0.value = ''; op0.textContent = 'Puesto'; select.appendChild(op0);
    }
    list.forEach(p => {
      const o = document.createElement('option');
      o.value = p.id; o.textContent = p.nombre; select.appendChild(o);
    });
  }

  // ====== Cargar filtros iniciales ======
  async function loadFiltros() {
    const deptos = await loadDepartamentosCatalog();
    renderDeptosOptions(document.getElementById('empDepto'), deptos, true);
    renderDeptosOptions(document.getElementById('empDeptoEdit'), deptos);

    const puestos = await loadPuestosCatalog();
    renderPuestosOptions(document.getElementById('empPuesto'), puestos, true);
    renderPuestosOptions(document.getElementById('empPuestoEdit'), puestos);

    // combo jefes
    const page = await loadEmpleadosPageForJefes(100);
    const jefeSel = document.getElementById('empJefe');
    if (jefeSel) {
      jefeSel.innerHTML = '<option value="">(Sin jefe)</option>';
      page.content.forEach(e => {
        const opt = document.createElement('option');
        opt.value = e.id; opt.textContent = `${e.nombres} ${e.apellidos}`; jefeSel.appendChild(opt);
      });
    }
  }

  // ====== Listado + paginación ======
  async function loadEmpleados() {
    const q = (document.getElementById('empSearch')?.value || '').trim();
    const estado = document.getElementById('empEstado')?.value || '';
    const dep = document.getElementById('empDepto')?.value || '';
    const puesto = document.getElementById('empPuesto')?.value || '';

    const url = new URL(`${baseUrl}/api/rrhh/empleados`, location.origin);
    url.searchParams.set('page', empPage);
    url.searchParams.set('size', empSize);
    url.searchParams.set('sort', empSort);
    if (q) url.searchParams.set('q', q);
    if (estado) url.searchParams.set('estado', estado);
    if (dep) url.searchParams.set('departamentoId', dep);
    if (puesto) url.searchParams.set('puestoId', puesto);

    const page = await http(url.toString());
    const tbody = document.getElementById('empTableBody');
    tbody.innerHTML = '';

    page.content.forEach(e => {
      const stateCls = e.estado === 'A' ? 'bg-success' : (e.estado === 'S' ? 'bg-warning' : 'bg-secondary');
      const nombre = `${e.nombres || ''} ${e.apellidos || ''}`.trim();
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${e.codigo || ''}</td>
        <td>${nombre}</td>
        <td>${e.dpi || ''}</td>
        <td>${e.puestoNombre || ''}</td>
        <td>${e.departamentoNombre || ''}</td>
        <td><span class="badge ${stateCls}">${e.estado || ''}</span></td>
        <td class="text-end">
          <button class="btn btn-sm btn-light me-2" data-edit-emp="${e.id}">Editar</button>
          <button class="btn btn-sm btn-danger" data-del-emp="${e.id}">Eliminar</button>
        </td>`;
      tbody.appendChild(tr);
    });

    const info = document.getElementById('empResultInfo');
    if (info) info.innerText = `Mostrando ${page.number * page.size + 1}–${page.number * page.size + page.numberOfElements} de ${page.totalElements}`;

    renderPagination(document.getElementById('empPagination'), page.number, page.totalPages, (p) => { empPage = p; loadEmpleados(); });
  }

  // ====== Delegación de acciones tabla ======
  function bindTabla() {
    const tbody = document.getElementById('empTableBody');
    if (!tbody) return;
    tbody.addEventListener('click', async (ev) => {
      const editId = ev.target.getAttribute('data-edit-emp');
      const delId = ev.target.getAttribute('data-del-emp');
      if (editId) {
        await openModalEditar(editId);
      } else if (delId) {
        if (!confirm('¿Eliminar empleado?')) return;
        await http(`${baseUrl}/api/rrhh/empleados/${delId}`, { method: 'DELETE' });
        showToast('Empleados', 'Empleado eliminado', 'success');
        loadEmpleados();
        loadDashboardKPIs();
      }
    });
  }

  // ====== Modal crear/editar ======
  let modalEmpleado;
  function ensureModal() {
    if (!modalEmpleado) modalEmpleado = new bootstrap.Modal('#modalEmpleado');
    return modalEmpleado;
  }

  async function openModalNuevo() {
    await loadFiltros();
    fillEmpleadoForm(null);
    document.getElementById('modalEmpleadoTitle').innerText = 'Nuevo empleado';
    ensureModal().show();
  }
  async function openModalEditar(id) {
    await loadFiltros();
    const dto = await http(`${baseUrl}/api/rrhh/empleados/${id}`);
    fillEmpleadoForm(dto);
    document.getElementById('modalEmpleadoTitle').innerText = 'Editar empleado';
    ensureModal().show();
  }

  function fillEmpleadoForm(emp) {
    const set = (id, val) => { const el = document.getElementById(id); if (el) el.value = val ?? ''; };
    set('empId', emp?.id);
    set('empCodigo', emp?.codigo);
    set('empNombres', emp?.nombres);
    set('empApellidos', emp?.apellidos);
    set('empDpi', emp?.dpi);
    set('empNit', emp?.nit);
    set('empTelefono', emp?.telefono);
    set('empEmail', emp?.email);
    set('empDireccion', emp?.direccion);
    set('empFechaIngreso', emp?.fechaIngreso);
    set('empFechaNac', emp?.fechaNacimiento);
    set('empEstadoEdit', emp?.estado || 'A');
    set('empDeptoEdit', emp?.departamentoId);
    set('empPuestoEdit', emp?.puestoId);
    set('empJefe', emp?.jefeId);
    set('empFoto', emp?.foto);
  }

  function bindModalSubmit() {
    const form = document.getElementById('formEmpleado');
    if (!form) return;
    form.addEventListener('submit', async (ev) => {
      ev.preventDefault();
      const id = document.getElementById('empId').value || null;
      const body = {
        codigo: (document.getElementById('empCodigo').value || '').trim(),
        nombres: (document.getElementById('empNombres').value || '').trim(),
        apellidos: (document.getElementById('empApellidos').value || '').trim(),
        dpi: (document.getElementById('empDpi').value || '').trim(),
        nit: (document.getElementById('empNit').value || '').trim() || null,
        telefono: (document.getElementById('empTelefono').value || '').trim() || null,
        email: (document.getElementById('empEmail').value || '').trim() || null,
        direccion: (document.getElementById('empDireccion').value || '').trim() || null,
        fechaIngreso: document.getElementById('empFechaIngreso').value || null,
        fechaNacimiento: document.getElementById('empFechaNac').value || null,
        estado: document.getElementById('empEstadoEdit').value || 'A',
        puestoId: document.getElementById('empPuestoEdit').value ? parseInt(document.getElementById('empPuestoEdit').value) : null,
        jefeInmediatoId: document.getElementById('empJefe').value ? parseInt(document.getElementById('empJefe').value) : null,
        foto: document.getElementById('empFoto').value || null
      };
      const url = id ? `${baseUrl}/api/rrhh/empleados/${id}` : `${baseUrl}/api/rrhh/empleados`;
      const method = id ? 'PUT' : 'POST';
      try {
        await http(url, { method, body: JSON.stringify(body) });
        ensureModal().hide();
        showToast('Empleados', `Empleado ${id ? 'actualizado' : 'creado'}`, 'success');
        await loadEmpleados();
        await loadDashboardKPIs();
      } catch (e) {
        showToast('Empleados', e.message, 'error');
      }
    });
  }

  // ====== Init módulo ======
  async function initEmpleados() {
    bindToolbar();
    bindTabla();
    bindModalSubmit();
    await loadEmpleados();
  }

  global.RRHH_Empleados = { initEmpleados, loadEmpleados };
})(window);
